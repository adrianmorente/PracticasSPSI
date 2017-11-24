# Práctica 3 - Seguridad y Protección de Sistemas Informáticos
### Adrián Morente Gabaldón

***

### 1. Generad un archivo sharedDSA.pem que contenga los parámetros. Mostrad los valores.

```
openssl dsaparam -out sharedDSA.pem 4096
```

***

### 2. Generad dos parejas de claves para los parámetros anteriores. Las claves se almacenarán en los archivos adrianDSAkey.pem y apellidoDSAkey.pem. No es necesario protegerlas con contraseña.

```
openssl gendsa sharedDSA.pem -out adrianDSAkey.pem
openssl gendsa sharedDSA.pem -out morenteDSAkey.pem
```

***

### 3. "Extraed" la clave privada contenida en el archivo adrianDSAkey.pem a otro archivo que tenga por nombre adrianDSApriv.pem. Este archivo deberá estar protegido por contraseña. Mostrad sus valores. Lo mismo para el archivo morenteDSAkey.pem.

```
openssl dsa -in adrianDSAkey.pem -aes128 -out adrianDSApriv.pem
openssl dsa -in adrianDSApriv.pem -text -noout
openssl dsa -in morenteDSAkey.pem -aes128 -out morenteDSApriv.pem
openssl dsa -in morenteDSApriv.pem -text -noout
```

***

### 4. Extraed en adrianDSApub.pem la clave pública contenida en el archivo adrianDSAkey.pem. De nuevo adrianDSApub.pem no debe estar cifrado ni protegido. Mostrad sus valores. Lo mismo para el archivo morenteDSAkey.pem.

```
openssl dsa -in adrianDSAkey.pem -pubout adrianDSApub.pem
openssl dsa -in adrianDSApub.pem -text -noout
openssl dsa -in morenteDSAkey.pem -pubout morenteDSApub.pem
openssl dsa -in morenteDSApub.pem -text -noout
```

***

### 5. Calculad el valor hash del archivo con la clave pública adrianDSApub.pem usando sha384 con salida hexadecimal con bloques de dos caracteres separados por dos puntos. Mostrad los valores por salida estándar y guardadlo en adrianDSApub.sha384.



***

### 6. Calculad el valor hash del archivo con la clave pública morenteDSApub.pem usando una función hash de 160 bits con salida binaria. Guardad el hash en morenteDSApub.[algoritmo] y mostrad su contenido.

***

### 7. Generad el valor HMAC del archivo sharedDSA.pem con clave '12345' mostrándolo por pantalla.

***

### 8. Simulad una ejecución completa del protocolo Estación a Estación. Para ello emplearemos como claves para firma/verificación las generadas en esta práctica, y para el protocolo DH emplearemos las claves asociadas a curvas elípticas de la práctica anterior junto con las de otro usuario simulado que deberéis generar nuevamente. Por ejemplo, si mi clave privada está en javierECpriv.pem y la clave pública del otro usuario está en lobilloECpub.pem, el comando para generar la clave derivada será `$ openssl pkeyutl -inkey javierECpriv.pem -peerkey lobilloECpub.pem -derive -out key.bin`. El algoritmo simétrico a utilizar en el protocolo estación a estación será AES-128 en modo CFB8.

***
