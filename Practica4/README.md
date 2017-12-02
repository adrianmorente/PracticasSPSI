# Práctica 4 - Seguridad y Protección de Sistemas Informáticos
## CERTIFICADOS DIGITALES
### Adrián Morente Gabaldón

***

### Comandos de utilidad para esta práctica (deben ser complementados con sus opciones pertinentes):

> - Uso y gestión de Autoridades de Certificación, así como firma de certificados:

> `$ openssl ca`

> - Solicitud de certificados a CA, con claves creadas previamente (o en el acto sobre RSA):

> `$ openssl req`

> - Manipulación de certificados previamente creados:

> `$ openssl x509`

***

Si ejecutamos `$ openssl ca` sin ningún parámetro nos lanza algunos errores advirtiendo que no existe ninguna Autoridad de Certificación en el sistema. Además, nos dice que la configuración cargada por el programa se encuentra bajo la ruta `/usr/lib/ssl/openssl.cnf`. Para aprender a trabajar con él, haremos una copia de seguridad en `/usr/lib/ssl/openssl.cnf.BACKUP` de forma que si hacemos que OpenSSL deje de funcionar como debe, podamos volver atrás y arreglarlo. Veamos un pequeño fragmento de su contenido (que no es poco):

```
####################################################################
[ ca ]
default_ca	= CA_default		# The default ca section

####################################################################
[ CA_default ]

dir		= ./demoCA		# Where everything is kept
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

Por otro lado, también podemos (y debemos, en un caso real) modificar los parámetros pertenecientes a la Autoridad de Certificación en sí; como por ejemplo la ubicación, el nombre de la organización y un correo de contacto.

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
organizationalUnitName	= optional -
commonName		= supplied
emailAddress		= optional

# For the 'anything' policy
# At this point in time, you must list all acceptable 'object'
# types.
[ policy_anything ]
countryName		= optional - MODIFICADO *Spain*
stateOrProvinceName	= optional - MODIFICADO *Granada*
localityName		= optional - MODIFICADO *La Chana*
organizationName	= optional - MODIFICADO *SPSI*
organizationalUnitName	= optional - MODIFICADO *SPSI*
commonName		= supplied - MODIFICADO *SPSI*
emailAddress		= optional - MODIFICADO *adrianmorente@correo.ugr.es*
```

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
countryName			= Country Name (2 letter code)
countryName_default		= AU
countryName_min			= 2
countryName_max			= 2

stateOrProvinceName		= State or Province Name (full name)
stateOrProvinceName_default	= Some-State

localityName			= Locality Name (eg, city)
```

***

### 1. Crear una autoridad certificadora. En este caso se premiará el uso de `openssl ca` frente a `CA.pl`, aunque este último comando es admisible.

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
