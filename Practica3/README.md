# Práctica 3 - Seguridad y Protección de Sistemas Informáticos
### Adrián Morente Gabaldón

***

### 1. Generad un archivo sharedDSA.pem que contenga los parámetros. Mostrad los valores.

La generación de los parámetros (los primos `p` y `q` y el generador `g`) se realiza rápidamente con el siguiente comando.

```
$ openssl dsaparam -out sharedDSA.pem 512
```

`sharedDSA.pem` será el fichero de destino donde se alojen dichos parámetros, y 512 es el tamaño en bits de los primos para su generación. Podría ser otro valor de nuestra elección. Durante el proceso de generación, obtendremos lo siguiente:

```
Generating DSA parameters, 512 bit long prime
This could take some time
.....+.......................................+++++++++++++++++++++++++++++++++++++++++++++++++++*
.......+.....+....+...........................+.+........+.+..+..............+.......+...+........+.....................+.........................+.........+......................+..+.........+..+.........+...+...........+....+....+.+................+++++++++++++++++++++++++++++++++++++++++++++++++++*
```

El contenido en ASCII del fichero con los parámetros generados es el siguiente:

```
-----BEGIN DSA PARAMETERS-----
MIGcAkEA7SejDVL59z7bj1eD2igCR0sqUwLTXFE3Lw7F0/RaOR+R/JSM1+ixmGzN
hHa9lLdQ1/iiUuZyfyUBtszz4mMC6wIVAJE4/ZUpC6T1ovV84d46ORh8o6qLAkAD
prVKo70YFqIexVy/Werp7/VerqK7El4QkVUqAZS2ND2wl2Zd3eCfN/EnM0C2kGyu
zzFoC+NJzdVBl+MgbZzH
-----END DSA PARAMETERS-----
```

Podremos ver estos parámetros en hexadecimal una vez que hayamos generado los pares de claves en los próximos ejercicios.

***

### 2. Generad dos parejas de claves para los parámetros anteriores. Las claves se almacenarán en los archivos adrianDSAkey.pem y apellidoDSAkey.pem. No es necesario protegerlas con contraseña.

Como para esta práctica trabajaremos con dos usuarios, necesitaremos crear un par de claves para cada uno de ellos. Éstos serán `adrian` y `morente`. El comando a seguir será igual para ambos (cambiando el fichero de destino):

```
$ openssl gendsa sharedDSA.pem -out adrianDSAkey.pem
$ openssl gendsa sharedDSA.pem -out morenteDSAkey.pem
```

`gendsa` es la directiva de OpenSSL para generar claves DSA; y requiere de un fichero de entrada que contenga los parámetros `p`, `q` y `g` antes mencionados.

Podemos mostrar el contenido de ambos ficheros con la directiva `dsa`, que sirve para manipular claves DSA ya generadas. Basta con especificar el fichero de entrada contenedor de dichas claves, seguido de `-text -noout` para que sean mostradas en hexadecimal y no en ASCII:

```
$ adrianDSAkey.pem

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

Por otro lado:

```
$ morenteDSAkey.pem

read DSA key
Private-Key: (512 bit)
priv:
    42:34:c1:77:9f:3d:ca:1f:b6:20:f3:75:37:f1:93:
    48:8d:f5:9d:09
pub:
    00:93:ba:fb:c4:44:59:da:6f:fb:3b:c0:4b:99:15:
    a5:d2:0a:64:ee:3e:26:bc:48:aa:9d:96:c3:37:7a:
    e8:2c:66:77:33:66:67:ad:60:fe:36:1d:e0:fd:34:
    3e:f3:11:c0:a4:b6:a9:93:c9:4b:bd:53:70:bf:1e:
    4e:a1:92:d4:87
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

Lógicamente, los parámetros `P`, `Q` y `G` son idénticos en ambos casos, ya que tienen el mismo origen.

***

### 3. "Extraed" la clave privada contenida en el archivo adrianDSAkey.pem a otro archivo que tenga por nombre adrianDSApriv.pem. Este archivo deberá estar protegido por contraseña. Mostrad sus valores. Lo mismo para el archivo morenteDSAkey.pem.

+ Cada una de las partes implicadas deberá proteger su clave privada de forma que solo la misma tenga acceso a ella. Ésto podemos hacerlo en OpenSSL con diversos criptosistemas, pero en este caso usaremos AES-128. Bastará con añadir la opción `-aes128`.
+ Especificaremos también el archivo de entrada del que extraer la clave privada.
+ Además, nombraremos el fichero de salida donde guardar dicha clave protegida.

Con los comandos siguientes extraemos las claves:

```
$ openssl dsa -in adrianDSAkey.pem -aes128 -out adrianDSApriv.pem
$ openssl dsa -in morenteDSAkey.pem -aes128 -out morenteDSApriv.pem
```

Y con los siguientes, las mostramos en formato hexadecimal:

```
$ openssl dsa -in adrianDSApriv.pem -text -noout
$ openssl dsa -in morenteDSApriv.pem -text -noout
```

La salida de estas últimas instrucciones contiene lo mismo mostrado en el ejercicio anterior, lógicamente. O por otro lado, si queremos **solamente la clave privada**, obviamos las opciones `-text -noout` para verla en ASCII:

```
-----BEGIN DSA PRIVATE KEY-----
MIH3AgEAAkEA7SejDVL59z7bj1eD2igCR0sqUwLTXFE3Lw7F0/RaOR+R/JSM1+ix
mGzNhHa9lLdQ1/iiUuZyfyUBtszz4mMC6wIVAJE4/ZUpC6T1ovV84d46ORh8o6qL
AkADprVKo70YFqIexVy/Werp7/VerqK7El4QkVUqAZS2ND2wl2Zd3eCfN/EnM0C2
kGyuzzFoC+NJzdVBl+MgbZzHAkAi5gxnu0VxnMK6p2eHC/GV0I/ZXDTByLJB9BpQ
Fvw7GhrbCaH0vj7Mo7dg8T3yGfajlORgEAPCR27dmmABvG7UAhQZFse9EnhuaXl0
KwEyiaSvjC1mJw==
-----END DSA PRIVATE KEY-----
```

***

### 4. Extraed en adrianDSApub.pem la clave pública contenida en el archivo adrianDSAkey.pem. De nuevo adrianDSApub.pem no debe estar cifrado ni protegido. Mostrad sus valores. Lo mismo para el archivo morenteDSAkey.pem.

+ Lógicamente, las claves públicas nunca deberán estar protegidas por clave, ya que deberán ser conocidas por cualquier parte que tenga acceso a ellas.

Volveremos a utilizar la directiva `dsa` de OpenSSL, sustituyendo esta vez los ficheros de destino de claves privadas por los de claves públicas, obviando el algoritmo de encriptación, y añadiendo la opción `-pubout` que especifique que es la clave **pública** la que queremos obtener.

La extracción se realizará con los siguientes comandos para ambos casos:

```
$ openssl dsa -in adrianDSAkey.pem -out adrianDSApub.pem -pubout
$ openssl dsa -in morenteDSAkey.pem -out morenteDSApub.pem -pubout
```

Para la impresión de éstas, bastará con añadir la opción `-pubin` al comando de impresión del ejercicio anterior; ya que OpenSSL muestra las claves privadas si no le decimos que haga otra cosa:

```
$ openssl dsa -in adrianDSApub.pem -text -noout -pubin
$ openssl dsa -in morenteDSApub.pem -text -noout -pubin
```

Aunque ya se mostraron en el segundo ejercicio, el contenido de los ficheros, respectivamente, es el siguiente:

```
$ adrianDSApub.pem

read DSA key
pub:
    22:e6:0c:67:bb:45:71:9c:c2:ba:a7:67:87:0b:f1:
    95:d0:8f:d9:5c:34:c1:c8:b2:41:f4:1a:50:16:fc:
    3b:1a:1a:db:09:a1:f4:be:3e:cc:a3:b7:60:f1:3d:
    f2:19:f6:a3:94:e4:60:10:03:c2:47:6e:dd:9a:60:
    01:bc:6e:d4
P:   
    ...
```

```
$ morenteDSApub.pem

read DSA key
pub:
    00:93:ba:fb:c4:44:59:da:6f:fb:3b:c0:4b:99:15:
    a5:d2:0a:64:ee:3e:26:bc:48:aa:9d:96:c3:37:7a:
    e8:2c:66:77:33:66:67:ad:60:fe:36:1d:e0:fd:34:
    3e:f3:11:c0:a4:b6:a9:93:c9:4b:bd:53:70:bf:1e:
    4e:a1:92:d4:87
```

A continuación de las claves públicas, se nos muestran los parámetros con que se generaron, pero los obviaremos ya que los hemos visto en ejercicios previos.

***

### 5. Calculad el valor hash del archivo con la clave pública adrianDSApub.pem usando sha384 con salida hexadecimal con bloques de dos caracteres separados por dos puntos. Mostrad los valores por salida estándar y guardadlo en adrianDSApub.sha384.



***

### 6. Calculad el valor hash del archivo con la clave pública morenteDSApub.pem usando una función hash de 160 bits con salida binaria. Guardad el hash en morenteDSApub.[algoritmo] y mostrad su contenido.

***

### 7. Generad el valor HMAC del archivo sharedDSA.pem con clave '12345' mostrándolo por pantalla.

***

### 8. Simulad una ejecución completa del protocolo Estación a Estación. Para ello emplearemos como claves para firma/verificación las generadas en esta práctica, y para el protocolo DH emplearemos las claves asociadas a curvas elípticas de la práctica anterior junto con las de otro usuario simulado que deberéis generar nuevamente. Por ejemplo, si mi clave privada está en javierECpriv.pem y la clave pública del otro usuario está en lobilloECpub.pem, el comando para generar la clave derivada será `$ openssl pkeyutl -inkey javierECpriv.pem -peerkey lobilloECpub.pem -derive -out key.bin`. El algoritmo simétrico a utilizar en el protocolo estación a estación será AES-128 en modo CFB8.

***
