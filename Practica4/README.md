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

- **Una clave raíz** (`ca.key.pem`),
- **Un certificado raíz** (`ca.cert.pem`).

Además, en un entorno de trabajo real no existe una sola CA raíz, sino que de ésta "cuelgan" otras CAs subordinadas, que son las que pueden firmar certificados. La autoridad raíz solo se utiliza para crear nuevas subordinadas. Cuantas menos acciones realice y menos expuesta esté, mejor; ya que si se comprometiese su clave se vería comprometido **el entorno completo**.

Sin embargo, el problema que nos ocupa solo consta de una de estas autoridades que será la raíz, y será la que utilicemos a lo largo de estos ejercicios.

***

Si ejecutamos `$ openssl ca` sin ningún parámetro nos lanza algunos errores advirtiendo que no existe ninguna Autoridad de Certificación en el sistema. Además, nos dice que la configuración cargada por el programa se encuentra bajo la ruta `/usr/lib/ssl/openssl.cnf`. Para no tener que lidiar con usuarios `root` ni trastocar la configuración inicial de OpenSSL, haremos una copia de este archivo de configuración en otro directorio (`/home/adri/SPSI-CA` en mi caso). En este directorio tendremos carpetas llamadas `certs`, `crl`, `newcerts` y `private`; necesarias para según qué tareas de una CA; y cuya definición se contempla en el archivo de configuración que vamos a describir.

Veamos un pequeño fragmento de su contenido (que no es poco). Para empezar, veamos la sección donde se establece el directorio principal de la CA, que por defecto es `/etc/ssl/demoCA` pero no existe. Lo lógico en un caso real sería alojar estas claves en el directorio `home` del usuario root correspondiente, pero usaremos el directorio mencionado arriba:

```
####################################################################
[ ca ]
default_ca	= CA_default		# The default ca section

####################################################################
[ CA_default ]

dir		= ./demoCA		# Where everything is kept - MODIFICADO */home/adri/SPSI-CA*
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

Para terminar, en el apartado `req` se especifican las opciones configurables a tener en cuenta al crear certificados o solicitudes de firmas. Tenemos la posibilidad de modificar parámetros como el número de bits usados en la generación de una clave, el fichero de destino para dicha clave, o las extensiones utilizadas sobre el estándar x509 (que dejaremos con valor por defecto).

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

[ req_distinguished_name ]
countryName			= Country Name (2 letter code) - MODIFICADO *ES*
countryName_default		= AU - MODIFICADO *ES*
countryName_min			= 2
countryName_max			= 2

stateOrProvinceName		= State or Province Name (full name)
stateOrProvinceName_default	= Some-State

localityName			= Locality Name (eg, city) - MODIFICADO *La Chana*
```

***

### 1. Crear una autoridad certificadora. En este caso se premiará el uso de `openssl ca` frente a `CA.pl`, aunque este último comando es admisible.

Una vez que hemos ajustado a nuestro antojo los parámetros del archivo antes visto, podemos proceder a la creación de la Autoridad de Certificación. Sin embargo, si nos limitamos a cambiar sus parámetros nos encontraremos con el siguiente error:

```
$ openssl ca

Using configuration from /usr/lib/ssl/openssl.cnf
Error opening CA private key ./demoCA/private/cakey.pem
140697338933056:error:02001002:system library:fopen:No such
    file or directory:bss_file.c:398:fopen('./demoCA/private/cakey.pem','r')
140697338933056:error:20074002:BIO routines:FILE_CTRL:system lib:bss_file.c:400:
unable to load CA private key
```

Esto se debe a que la clave privada perteneciente a la CA **no existe**, ya que no la hemos creado. OpenSSL busca dicha clave, como dice en el mensaje, bajo el fichero `/usr/lib/ssl/private/cakey.pem`. Necesitaremos permisos de superusuario para crearlo/modificarlo. Además, si queremos evitar futuros problemas de permisos deberíamos dotar al usuario de permiso de lectura para la carpeta `private` (que no es más que un enlace al directorio `/etc/ssl/.`) a nuestro usuario local. Insisto en que esto es una simulación, y en un caso real se deberían alojar las claves usadas en el directorio del usuario.

En este caso utilizaré una de las claves ya usadas en prácticas anteriores (concretamente, se corresponde con la del archivo `adrianDSAkey.pem` de la Práctica 3). Podemos examinar el contenido con el comando `$ openssl dsa -in /usr/lib/ssl/private/cakey.pem -text -noout`:

```
$ /usr/lib/ssl/private/cakey.pem

read DSA key
Private-Key: (512 bit)
priv:
    19:16:c7:bd:12:78:6e:69:79:74:2b:01:32:89:a4:
    af:8c:2d:66:27
pub:
    22:e6:0c:67:bb:45:71:9c:c2:ba:a7:67:87:0b:f1:
    95:d0:8f:d9:5c:34:c1:c8:b2:41:f4:1a:50:16:fc:
    3b:1a:1a:db:09:a1:f4:be:3e:cc:a3:b7:60:f1:3d:
    f2:19:f6:a3:94:e4:60:10:03:c2:47:6e:dd:9a:60:
    01:bc:6e:d4
P:   
    00:ed:27:a3:0d:52:f9:f7:3e:db:8f:57:83:da:28:
    02:47:4b:2a:53:02:d3:5c:51:37:2f:0e:c5:d3:f4:
    5a:39:1f:91:fc:94:8c:d7:e8:b1:98:6c:cd:84:76:
    bd:94:b7:50:d7:f8:a2:52:e6:72:7f:25:01:b6:cc:
    f3:e2:63:02:eb
Q:   
    00:91:38:fd:95:29:0b:a4:f5:a2:f5:7c:e1:de:3a:
    39:18:7c:a3:aa:8b
G:   
    03:a6:b5:4a:a3:bd:18:16:a2:1e:c5:5c:bf:59:ea:
    e9:ef:f5:5e:ae:a2:bb:12:5e:10:91:55:2a:01:94:
    b6:34:3d:b0:97:66:5d:dd:e0:9f:37:f1:27:33:40:
    b6:90:6c:ae:cf:31:68:0b:e3:49:cd:d5:41:97:e3:
    20:6d:9c:c7
```

Una vez que hemos solventado los errores de lectura y permisos del fichero, podemos proceder a crear la Autoridad de Certificación con el comando `$ openssl ca` como antes:



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
