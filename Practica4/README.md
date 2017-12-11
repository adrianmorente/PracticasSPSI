# Práctica 4 - Seguridad y Protección de Sistemas Informáticos
## CERTIFICADOS DIGITALES
### Adrián Morente Gabaldón

***

Antes de comenzar con los ejercicios, vamos a comentar algunos aspectos relevantes con respecto a la práctica, y la configuración del archivo utilizado por OpenSSL para Autoridades de Certificación.

### Comandos de utilidad para esta práctica (deben ser complementados con sus opciones pertinentes):

> - Uso y gestión de Autoridades de Certificación, así como firma de certificados:

> `$ openssl ca`

> - Solicitud de certificados a CA, con claves creadas previamente (o en el acto sobre RSA):

> `$ openssl req`

> - Manipulación de certificados previamente creados:

> `$ openssl x509`

***

Para empezar, debemos saber que la identidad de una Autoridad de Certificación se compone de dos cosas:

- **Una clave raíz** (`cakey.pem`),
- **Un certificado raíz** (`cacert.pem`).

Además, en un entorno de trabajo real no existe una sola CA raíz, sino que de ésta "cuelgan" otras CAs subordinadas, que son las que pueden firmar certificados. La autoridad raíz solo se utiliza para crear nuevas subordinadas. Cuantas menos acciones realice y menos expuesta esté, mejor; ya que si se comprometiese su clave se vería comprometido **el entorno completo**.

Sin embargo, el problema que nos ocupa solo consta de una de estas autoridades que será la raíz, y será la que utilicemos a lo largo de estos ejercicios.

***

Si ejecutamos `$ openssl ca` sin ningún parámetro nos lanza algunos errores advirtiendo que no existe ninguna Autoridad de Certificación en el sistema. Además, nos dice que la configuración cargada por el programa se encuentra bajo la ruta `/usr/lib/ssl/openssl.cnf`. Para no tener que lidiar con usuarios `root` ni trastocar la configuración inicial de OpenSSL, haremos una copia de este archivo de configuración en otro directorio (`./ca` en mi caso). En este directorio tendremos carpetas llamadas `certs`, `crl`, `newcerts` y `private`; necesarias para según qué tareas de una CA; y cuya definición se contempla en el archivo de configuración que vamos a describir.

Veamos un pequeño fragmento de su contenido (que no es poco). Para empezar, veamos la sección donde se establece el directorio principal de la CA, que por defecto es `/etc/ssl/demoCA` pero no existe. Lo lógico en un caso real sería alojar estas claves en el directorio `home` del usuario root correspondiente, pero usaremos el directorio mencionado arriba:

```
####################################################################
[ ca ]
default_ca	= CA_default		# The default ca section

####################################################################
[ CA_default ]

dir		= ./demoCA		# Where everything is kept - MODIFICADO *./ca*
```

En el directorio `dir` arriba mencionado se almacenan todos los ficheros y variables configurables. Algunas de ellas se ven a continuación, y encontramos cosas como el almacenamiento de certificados creados (en la variable `certs`), el número de serie de la CA (en `serial`), etc.:

```
certs		= $dir/certs		# Where the issued certs are kept
crl_dir		= $dir/crl		# Where the issued crl are kept
database	= $dir/index.txt	# database index file.
#unique_subject	= no			# Set to 'no' to allow creation of
					                # several ctificates with same subject.
new_certs_dir	= $dir/newcerts		# default place for new certs.

certificate	= $dir/cacert.pem 	# The CA certificate
serial		= $dir/serial 		# The current serial number
crlnumber	= $dir/crlnumber	# the current crl number
					# must be commented out to leave a V1 CRL
crl		= $dir/crl.pem 		# The current CRL
private_key	= $dir/private/cakey.pem# The private key
RANDFILE	= $dir/private/.rand	# private random number file

x509_extensions	= usr_cert		# The extentions to add to the cert

# Comment out the following two lines for the "traditional"
# (and highly broken) format.
name_opt 	= ca_default		# Subject Name options
cert_opt 	= ca_default		# Certificate field options
```

En esta otra parte podemos modificar cosas como el tiempo de expiración de los certificados expedidos, que por defecto es de 365 días y que pondré a 120 por cambiar algo. Además, podemos alterar el tiempo de revisión de la ***Lista de Revocación de Certificados*** (o *CRL*):

```
default_days	= 365			# how long to certify for - MODIFICADO A 120
default_crl_days= 30			# how long before next CRL - MODIFICADO A 15
default_md	= default		# use public key default MD
preserve	= no			# keep passed DN ordering
```

Por otro lado, también podemos (y debemos, en un caso real) modificar los parámetros pertenecientes a la política de solicitudes que debe aceptar la Autoridad de Certificación. Permite establecer políticas de restricción de firma y certificación por el país de origen del solicitante, por ejemplo.

```
# A few difference way of specifying how similar the request should look
# For type CA, the listed attributes must be the same, and the optional
# and supplied fields are just that :-)
policy		= policy_match

# For the CA policy
[ policy_match ]
countryName		= match - MODIFICADO *Spain*
stateOrProvinceName	= match - MODIFICADO *Granada*
organizationName	= match - MODIFICADO *SPSI*
organizationalUnitName	= optional - MODIFICADO *SPSI*
commonName		= supplied
emailAddress		= optional - MODIFICADO *adrianmorente@correo.ugr.es*

```

En el apartado `req` se especifican las opciones configurables a tener en cuenta al crear certificados o solicitudes de firmas. Tenemos la posibilidad de modificar parámetros como el número de bits usados en la generación de una clave, el fichero de destino para dicha clave, o las extensiones utilizadas sobre el estándar x509 (que dejaremos con valor por defecto).

```
####################################################################
[ req ]
default_bits		= 2048 - MODIFICADO *4096*
default_keyfile 	= privkey.pem
distinguished_name	= req_distinguished_name
attributes		= req_attributes
x509_extensions	= v3_ca	# The extentions to add to the self signed cert

# Passwords for private keys if not present they will be prompted for
# input_password = secret
# output_password = secret

# This sets a mask for permitted string types. There are several options.
# default: PrintableString, T61String, BMPString.
# pkix	 : PrintableString, BMPString (PKIX recommendation before 2004)
# utf8only: only UTF8Strings (PKIX recommendation after 2004).
# nombstr : PrintableString, T61String (no BMPStrings or UTF8Strings).
# MASK:XXXX a literal mask value.
# WARNING: ancient versions of Netscape crash on BMPStrings or UTF8Strings.
string_mask = utf8only

# req_extensions = v3_req # The extensions to add to a certificate request
```

Por otro lado, en la sección `[req_distinguished_name]` declaramos la información requerida para una petición de firma de certificado (esto es, el mensaje impreso en la terminal cuando realizamos una solicitud).

```
[ req_distinguished_name ]
countryName			= Country Name (2 letter code)
countryName_default		= AU
countryName_min			= 2
countryName_max			= 2

stateOrProvinceName		= State or Province Name (full name)
stateOrProvinceName_default	= Some-State

localityName			= Locality Name (eg, city)
```

Existen otros apartados y secciones como `[ usr_cert ]` y `[ server_cert ]`, que se aplican a la firma de certificados de cliente y servidor, respectivamente. Existen otras secciones menos relevantes o de menos utilidad para nuestro caso, así que las obviaremos.

***

### 1. Crear una autoridad certificadora. En este caso se premiará el uso de `openssl ca` frente a `CA.pl`, aunque este último comando es admisible.

Una vez que hemos ajustado los parámetros de configuración deseados, si queremos crear la Autoridad de Certificación necesitamos las dos partes antes mencionadas, la clave raíz y el certificado raíz.

##### 1.1. **Clave raíz**:

Dentro del directorio creado al efecto (o en `/root/ca` en un caso real), ejecutamos la orden ya conocida para generar una clave, fijando como destino el directorio `/private`. Esto es obvio ya que esta clave se utilizará para emitir certificados confiables, por lo que **nadie** debe tener acceso a ella:

```
$ openssl genrsa -aes256 -out private/cakey.pem 4096
```

Protegemos el archivo `cakey.pem` con la contraseña `0123456789` usando AES256 y con una longitud de 4096 bytes.

<img src="./capturas/claveCAbloqueada.png" width="50%" alt="claveCAbloqueada.png"><img src="./capturas/claveCAvalor.png" width="50%" alt="claveCAvalor.png">

##### 1.2. **Certificado raíz**:

Una vez que tenemos la clave raíz, podemos usarla para crear el certificado raíz, que será un **certificado autofirmado**. Los parámetros de entrada al comando serán varios, en los que definimos (en este orden) el fichero de configuración, la clave raíz, el estándar seguido por el certificado (x509), los días de validez y el fichero de salida.

> En cuanto a la fecha de expiración, voy a usar 14 días porque se trata de una simulación sin efecto práctico. Pero en un caso real debería ser del orden de años; dado que una vez que expire este certificado raíz, todos los demás emitidos por la CA dejarán de tener validez alguna.

```
$ openssl req -config openssl.cnf -key private/cakey.pem -new -x509
		-days 14 -sha256 -out certs/cacert.pem
```

En cuanto ejecutamos el comando, se nos realizarán varias preguntas (las definidas en el fichero de configuración vistas con anterioridad) que deberemos cumplimentar para la creación del certificado autofirmado.

<img src="./capturas/certificadoCAcreacion.png" width="95%" alt="certificadoCAcreacion.png">

***

### 2. Cread una solicitud de certificado que incluya la generación de claves en la misma.

***

### 3. Cread un certificado para la solicitud anterior empleando la CA creada en el primer punto.

***

### 4. Cread una solicitud de certificado para cualquiera de las claves que habéis generado en las prácticas anteriores, excepto las RSA.

***

### 5. Cread un certificado para solicitud anterior utilizando la CA creada.

***

### 6. Emplead las opciones `-text` y `-noout` para mostrar los valores de todos los certificados y solicitudes de los puntos anteriores, incluyendo el certificado raíz que habrá sido creado junto con la CA.

***
