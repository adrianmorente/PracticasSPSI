# Práctica 2 - Seguridad y Protección de Sistemas Informáticos
### Adrián Morente Gabaldón

***

### 1. Generad cada uno de vosotros, una clave RSA (que contiene el par de claves) de 768 bits. Para referirnos a ella supondré que se llama nombreRSAkey.pem. Esta clave no es necesario que esté protegida por contraseña.

Generamos el par de claves fácilmente con el comando `openssl genrsa`, pasando como argumentos el fichero de destino (especificado por el enunciado del ejercicio) así como el número de bits de tamaño de la clave:

  `openssl genrsa -out AdrianRSAkey.pem 768`

Para este primer caso no la protegeremos con ninguna contraseña. El contenido es el siguiente:

<img src="./capturas/AdrianRSAkey.pem.bmp" width="80%" alt="AdrianRSAkey.pem.bmp">

---

### 2. "Extraed" la clave privada contenida en el archivo nombreRSAkey.pem a otro archivo que tenga por nombre nombreRSApriv.pem. Este archivo deberá estar protegido por contraseña cifrándolo con AES-128. Mostrad sus valores.

Una vez que la clave ha sido generada, usamos el comando `openssl rsa` para manipularla. En este caso usamos las opciones que nos permiten asignar un fichero de entrada del que obtenerla, y uno de salida con la operación aplicada:

- **-in** / **-out**: con el primero indicamos el fichero de entrada, y con el segundo el de salida.
- **-aes128**: este es el indicativo sobre qué método de cifrado aplicar al resultado con la contraseña elegida. Existen otras alternativas ya conocidas como *-des*.

El comando completo sería el siguiente, y a continuación una captura con el resultado:

`openssl rsa -in AdrianRSAkey.pem -out AdrianRSApriv.pem -aes128`

<img src="./capturas/AdrianRSApriv.pem.bmp" width="80%" alt="AdrianRSApriv.pem.bmp">

---

### 3. Extraed en nombreRSApub.pem la clave pública contenida en el archivo nombreRSAkey.pem. Evidentemente nombreRSApub.pem no debe estar cifrado ni protegido. Mostrad sus valores.

Por defecto, cuando imprimimos el contenido del archivo contenedor de nuestro **par de claves**, solo se muestra la privada. Sin embargo, la pública también está ahí, solo que tenemos que usar la opción `-pubout` para que sea mostrada. Con el siguiente comando la obtenemos del fichero de entrada y la extraemos al fichero de salida:

`openssl rsa -in AdrianRSAkey.pem -out AdrianRSApub.pem -pubout`

Lógicamente, una clave pública no debe ser protegida con contraseña. El valor obtenido es:

<img src="./capturas/AdrianRSApub.pem.bmp" width="80%" alt="AdrianRSApub.pem.bmp">

---

### 4. Reutilizaremos el archivo binario input.bin de 1024 bits, todos ellos con valor 0, de la práctica anterior.

Recuperamos el fichero que tenía el siguiente contenido:

<img src="./capturas/input.bin.png" width="70%" alt="input.bin.png">

---

### 5. Intentad cifrar input.bin con vuestra clave pública. Explicad el resultado.

Para el ejemplo, vamos a intentar cifrar el archivo input.bin con *DES* en modo *ECB*, pasando como entrada la clave pública contenida en el archivo `AdrianRSApub.pem`:

`openssl rsautl -in binarios/input.bin -out binarios/input-rsa.bin -inkey AdrianRSApub.pem -pubin -encrypt`

Sin embargo, obtenemos el siguiente error:

```
RSA operation error
139685646712640:error:0406D06E:rsa routines:RSA_padding_add_PKCS1_type_2:data
too large for key size:rsa_pk1.c:153:
```

El error obtenido se debe a que RSA es un cifrado de flujo y no por bloques, así que no permite cifrar mensajes mayores que su clave.

---

### 6. Diseñad un cifrado híbrido, con RSA como criptosistema asimétrico. El modo de proceder será el siguiente:

  1. El emisor debe seleccionar un sistema simétrico con su correspondiente modo de operación.
  2. El emisor generará un archivo de texto, llamado por ejemplo `sessionkey` con dos líneas. La primera línea contendrá una cadena aleatoria hexadecimal cuya longitud sea la requerida por la clave. OpenSSL permite generar cadenas aleatorias con el comando `openssl rand`. La segunda línea contendrá la información del criptosistema simétrico seleccionado. Por ejemplo, si hemos decidido emplear el algoritmo Blowfish en modo ECB, la segunda línea debería contener `-bf-ecb`.
  3. El archivo `sessionkey` se cifrará con la clave pública del receptor.
  4. El mensaje se cifrará utilizando el criptosistema simétrico, la clave se generará a partir del archivo anterior mediante la opción `-pass file:sessionkey`.

---

  - Vamos a utilizar el sistema AES-256 en modo ECB, por lo que deberemos utilizar claves de 256 bits (32 Bytes exactamente) y bloques de 128 bits.
  - Deberemos crear el fichero `sessionkey` con una longitud de clave de 256 bits en la primera línea, con el comando `openssl rand -out sessionkey -hex 32`, y la opción -aes-256-ecb en la segunda.
  - Ahora pasamos a cifrar dicho archivo con la clave pública del receptor. Para este caso de ejemplo, utilizaremos la clave pública generada en los ejercicios anteriores, utilizando el comando visto en el ejercicio anterior:
  `openssl rsautl -in sessionkey -out encrypted-sessionkey -inkey AdrianRSApub.pem -pubin -encrypt`. Esto generará un contenido binario que no podemos visualizar en la terminal, pero sí en el editor hexadecimal:

  <img src="./capturas/encrypted-sessionkey.bmp" width="70%" alt="encrypted-sessionkey.bmp">

  - Ahora cifraremos con el sistema antes elegido (AES-256 en modo ECB) el mensaje, que para el caso volverá a ser el archivo input.bin. Esto lo hacemos fácilmente con el comando `openssl enc -aes-256-ecb -in binarios/input.bin -out binarios/input-aes-256-ecb.bin -pass file:sessionkey`. Una vez ejecutado, el archivo binario resultante *(el mensaje)* tendrá el siguiente contenido:

  <img src="./capturas/input-aes-256-ecb.bin.bmp" width="70%" alt="input-aes-256-ecb.bin.bmp">

---

### 7. Utilizando el criptosistema híbrido diseñado, cada uno debe cifrar el archivo input.bin con su clave pública para, a continuación, descifrarlo con la clave privada. Comparad el resultado con el archivo original.

El procedimiento que sigue el sistema es el siguiente:

  1. **(Emisor)** - Cifra el mensaje con la clave de sesión generada aleatoriamente.
  2. **(Emisor)** - Cifra la clave de sesión con la clave pública del receptor.
  3. **(Receptor)** - Descifra la clave de sesión encriptada, con su propia clave privada.
  4. **(Receptor)** - Descifra el mensaje con la clave de sesión obtenida en el paso anterior.

Con este método, nos aseguramos de que nadie salvo el receptor (quien se presupone el único conocedor de su clave privada) pueda desencriptar la clave de sesión y por tanto interferir en los mensajes. Se asegura la ***confidencialidad***.

  - Ahora bien, tras lo realizado en el ejercicio anterior, nos encontramos en el **tercer** paso, por lo que debemos desencriptar la clave de sesión con la clave privada del receptor. Esto lo hacemos con el comando:

  `openssl rsautl -in encrypted-sessionkey -out decrypted-sessionkey -inkey AdrianRSApriv.pem -decrypt`

  Si hacemos un `cat` al fichero `decrypted-sessionkey` observamos el siguiente contenido (que debe coincidir, y coincide con el `sessionkey` original):

  `118e4cab64e22241b3baacd27cfb65146b23967452588b2373e78bf8fbb662e9
  -aes-256-ecb`

  - Una vez obtenida la clave de sesión, el receptor al fin tiene acceso al mensaje, ya que esta `sessionkey` contiene la clave simétrica con la que se protegió dicho mensaje, y además indica el método con el que se cifró. Por tanto, ejecutamos el descifrado con el modo indicado de la siguiente forma:

  `openssl aes-256-ecb -d -in binarios/input-aes-256-ecb.bin -out binarios/decrypted-input-aes-256-ecb.bin -pass file:decrypted-sessionkey`

  - Para terminar, vemos que el archivo `input-aes-256-ecb.bin` tiene el mismo contenido que el mensaje original (`input.bin`):

  <img src="./capturas/decrypted-input-aes-256-ecb.bin.bmp" width="70%" alt="decrypted-input-aes-256-ecb.bin.bmp">

---

# Curvas elípticas

### 8. Generad un archivo stdECparam.pem que contenga los parámetros públicos de una de las curvas elípticas contenidas en las transparencias de teoría. Si no lográis localizarlas haced el resto de la práctica con una curva cualquiera a vuestra elección de las disponibles en OpenSSL. Mostrad los valores.

Si queremos ver las curvas elípticas disponibles en nuestra versión de OpenSSL podemos ejecutar el comando `openssl ecparam -list_curves`, que nos proporcionará una lista más o menos extensa con todas ellas.

Veamos algunas líneas de esta lista. Los conceptos clave y siglas más comunes se detallan al final del guión en el apartado de **Conceptos clave**.

```
secp160r2 : SECG/WTLS curve over a 160 bit prime field
secp224r1 : NIST/SECG curve over a 224 bit prime field
prime256v1: X9.62/SECG curve over a 256 bit prime field
sect193r2 : SECG curve over a 193 bit binary field
wap-wsg-idm-ecid-wtls12: WTLS curvs over a 224 bit prime field
brainpoolP224t1: RFC 5639 curve over a 224 bit prime field
Oakley-EC2N-4:
	IPSec/IKE/Oakley curve #4 over a 185 bit binary field.
	Not suitable for ECDSA.
	Questionable extension field!
```

La definición de los conceptos más *"extraños"* de esta lista la podemos consultar en el apartado de **Conceptos clave** al final de este guión.

Por mi parte, me quedaré por ejemplo con ***brainpoolP224t1***. Generaremos los parámetros públicos de esta curva con el comando `openssl ecparam -name brainpoolP224t1 -out stdECparam.pem -text`. El resultado obtenido en el fichero de salida `stdECparam.pem` es el siguiente:

```
ASN1 OID: brainpoolP224t1
-----BEGIN EC PARAMETERS-----
BgkrJAMDAggBAQY=
-----END EC PARAMETERS-----
```

La opción `-text` añade la primera línea de descripción al fichero, de forma que se pueda ver la [*Abstract Syntax Notation One*](https://es.wikipedia.org/wiki/ASN.1) utilizada. Ésta es una norma para representar datos independientemente de la máquina que se esté usando y sus formas de representación internas.

Si quisiéramos leer un fichero de esta notación que no incluya esa primera línea, podríamos usar un decodificador como éste: [http://lapo.it/asn1js](http://lapo.it/asn1js). Este es un ejemplo online, y si en el campo de texto insertamos la cadena de parámetros `BgkrJAMDAggBAQY=` nos decodificará esta cadena resultando en la siguiente salida, detallando la curva elíptica usada además de los parámetros de codificación que utiliza:

![brainpoolP224t1.png](./capturas/brainpoolP224t1.png)

---

### 9. Generad cada uno de vosotros una clave para los parámetros anteriores. La clave se almacenará en AdrianECkey.pem y no es necesario protegerla por contraseña.

Una vez que tenemos la curva elíptica elegida y sus parámetros, generamos la clave usando esos parámetros con el siguiente comando:

```bash
openssl ecparam -in stdECparam.pem -genkey -out AdrianECkey.pem
```

El contenido de la clave generada lo obtenemos mostrando el contenido del fichero. Como podemos apreciar, las 3 primeras líneas de dicho fichero nos muestran los parámetros obtenidos previamente y utilizados para la generación de la clave. Si no quisiéramos incluir esto en este archivo, bastaría con concatenar la opción ` -noout` al comando previo.

```
-----BEGIN EC PARAMETERS-----
BgkrJAMDAggBAQY=
-----END EC PARAMETERS-----
-----BEGIN EC PRIVATE KEY-----
MGwCAQEEHGPciDGsYujd4YhlfAYwlHaDw/Q3H6/NBnTxQwqgCwYJKyQDAwIIAQEG
oTwDOgAEbyQIlYF4GlO6BMlTwfMF8PDBsm7v5qyDgoKczD2xMr5cwYsal8LlyeqK
HKRX23mzR0VK7+6FdBM=
-----END EC PRIVATE KEY-----
```

---

### 10. "Extraed" la clave privada contenida en el archivo nombreECkey.pem a otro archivo que tenga por nombre nombreECpriv.pem. Este archivo deberá estar protegido por contraseña cifrándolo con 3DES. Mostrad sus valores.

Al igual que con `rsa` y `rsautl`, para las curvas elípticas tenemos dos comandos diferentes para la generación y el tratamiento de información, que son `ecparam` (usado antes) y `ec`, respectivamente. Para extraer las claves privada y pública utilizaremos este último de forma sencilla. Empezaremos por la privada con el siguiente comando:

`openssl ec -in AdrianECkey.pem -out AdrianECpriv.pem -des3`

Obviamente, la opción `-des3` asigna el cifrado 3DES al fichero para protegerlo con contraseña. Usaremos 0123456789 como venimos haciendo en toda la práctica. El contenido del fichero `AdrianECpriv.pem` generado es el siguiente:

```
-----BEGIN EC PRIVATE KEY-----
Proc-Type: 4,ENCRYPTED
DEK-Info: DES-EDE3-CBC,39539FF3980DFBBD

Muoajh01Cu4kQfx/S4ec2/rTzQX05pRmXsiwzM7AQDY6dxK2z81/BKAweHJQnzpw
QVHLIU1NtACdNYMaC+DkrbMCCSvrUjdp0TdWr62cZ3OYw/XUc5u/A7gsNd7BLxZS
kijK8aJ7JZUZ+12rRgIXGg==
-----END EC PRIVATE KEY-----
```

---

### 11. Extraed en nombreECpub.pem la clave pública contenida en el archivo nombreECkey.pem. Como antes nombreECpub.pem no debe estar cifrado ni protegido. Mostrad sus valores.

Con respecto a la clave pública el proceso es muy similar al del ejercicio anterior con la clave privada; quitando la protección con 3DES y añadiendo al comando tan solo la opción `-pubout`, ya que `openssl ec` coge por defecto la privada a no ser que le indiquemos hacer otra cosa.

`openssl ec -in AdrianECkey.pem -out AdrianECpub.pem -pubout`

El valor de la clave pública generada es éste:

```
-----BEGIN PUBLIC KEY-----
MFIwFAYHKoZIzj0CAQYJKyQDAwIIAQEGAzoABG8kCJWBeBpTugTJU8HzBfDwwbJu
7+asg4KCnMw9sTK+XMGLGpfC5cnqihykV9t5s0dFSu/uhXQT
-----END PUBLIC KEY-----
```

---

## Conceptos clave

- **SECG**: *Standards for Efficient Cryptography Group*, consorcio internacional fundado por [***Certicom***](https://www.certicom.com.pe/) en 1998, que desarrolla estándares para criptografía basada en curvas elípticas de forma eficiente. En este grupo entran grandes conglomerados como *Fujitsu*, *Entrust* y *VISA*.
- **WTLS**: *Wireless Transport Layer Security*, se trata de un protocolo de seguridad perteneciente al conjunto de protocolos **WAP** (*Wireless Application Protocol*). Deriva del protocolo *Transport Layer Security* y utiliza una semántica similar pero adaptada a dispositivos móviles con menor ancho de banda.
- **X9.62**: [AMERICAN NATIONAL STANDARD, Public Key Cryptography for the Financial Services Industry](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.202.2977&rep=rep1&type=pdf).
- **IPSec**: abreviatura de *Internet Protocol Security*. Conjunto de protocolos cuya función es asegurar las comunicaciones sobre IP autenticando y cifrando cada paquete en un flujo de datos.
- **IKE**: *Internet key exchange*, se trata de un protocolo usado sobre el protocolo IPSec. Utiliza un intercambio de claves *Diffie-Hellman* (visto en teoría) y suelen utilizar sistemas de clave pública o pre-compartida. Permite especificar el tiempo de vida de la sesión.
- **Oakley**: *Oakley Key Determination Protocol*, se trata de un protocolo de negociación de claves de sesión que permite a dos partes autenticadas establecer un canal de comunicación seguro sobre un medio que no lo es. Utiliza el conocido algoritmo *Diffie-Hellman*. Sentó las bases para el conocido *Internet key exchange* (mencionado arriba).
- **ECDSA**: *Elliptic Curve Digital Signature Algorithm*. Se trata de una modificación del algoritmo **DSA** (*Digital Signature Algorithm*) que emplea operaciones sobre puntos de curvas elípticas en lugar de las exponenciales que utiliza DSA. La ventaja es que brinda la misma seguridad con números de tamaño menor.

## Referencias

- Par de claves: [https://en.wikibooks.org/wiki/Cryptography/Generate_a_keypair_using_OpenSSL](https://en.wikibooks.org/wiki/Cryptography/Generate_a_keypair_using_OpenSSL)
- Generar claves RSA: [https://rietta.com/blog/2012/01/27/openssl-generating-rsa-key-from-command/](https://rietta.com/blog/2012/01/27/openssl-generating-rsa-key-from-command/)
- RFC sobre curvas elípticas: [https://www.ietf.org/rfc/rfc5480.txt](https://www.ietf.org/rfc/rfc5480.txt)
- *Elliptic Curves over Prime and Binary Fields in Cryptography*: [https://www.fields.utoronto.ca/programs/scientific/07-08/cryptography/dana_neustadter.pdf](https://www.fields.utoronto.ca/programs/scientific/07-08/cryptography/dana_neustadter.pdf)
- *IPSec*: [https://es.wikipedia.org/wiki/IPsec](https://es.wikipedia.org/wiki/IPsec)
- *SECG*: [https://en.wikipedia.org/wiki/SECG](https://en.wikipedia.org/wiki/SECG)
- *IKE*: [https://es.wikipedia.org/wiki/Internet_key_exchange](https://es.wikipedia.org/wiki/Internet_key_exchange)
- *ECDSA*: [https://es.wikipedia.org/wiki/ECDSA](https://es.wikipedia.org/wiki/ECDSA)
