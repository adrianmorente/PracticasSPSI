#!/usr/bin/ruby
require 'digest'
require 'securerandom'

n = 256

print "Introduce el texto: "
texto = gets.chomp

print "Introduce el número de ceros a buscar: "
bits_cero = gets.to_i

# 1º - buscar una cadena aleatoria de n bits (en hex, n/4)
nonce = SecureRandom.hex(n/4)

# 2º - concatenarle el texto, y guardar como id
id = nonce + texto

# 3º - empiezo bucle, busco otra cadena aleatoria de n bits
terminado = false
contador = 0
hash = ""
while not terminado do
  terminado = true
  contador += 1

  x = SecureRandom.hex(n/4)

  # 4º - la concateno al id, y le aplico el hash
  aux = id + x
  hash = Digest::SHA256.hexdigest aux

  # 5º - convertimos el hash de hex a bin para buscar los ceros
  hash_bin = hash.hex.to_s(2).rjust(hash.size*4, '0')

  # 6º - si los b primeros bits del hash son cero, salgo del bucle
  for i in 0..bits_cero-1
    if hash_bin[i] != "0" then
      terminado = false
    end
  end
end

# 7º - salida, imprimimos contador, valor del hash y éste último en binario
puts "ID: #{id}"
puts "Cadena aleatoria X: #{x}"
puts "Número de iteraciones: #{contador}"
puts "Hash de la solución (hex): #{hash}"
