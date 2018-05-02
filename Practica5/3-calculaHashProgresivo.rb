#!/usr/bin/ruby
require 'digest'
require 'securerandom'

n = 256

print "Introduce el texto: "
texto = gets.chomp

print "Introduce el número de ceros a buscar: "
bits_cero = gets.to_i

# buscar una cadena aleatoria de n bits (en hex, n/4)
nonce = SecureRandom.hex(n/4)

# concatenarle el texto, y guardar como id
id = nonce + texto

# empiezo bucle, busco otra cadena aleatoria de n bits
terminado = false
contador = 0
x = SecureRandom.hex(n/4)
aux = id + x
hash = Digest::SHA256.hexdigest aux

puts "x = #{x}"
puts "hash = #{hash}"

# mientras no encontremos bits_cero ceros al principio...
while not terminado do
  terminado = true
  contador += 1

  # convertimos el hash de hex a bin para buscar los ceros
  # convertimos x de string a binario para sumarle 1
  hash_bin = x.hex.to_s(2).rjust(x.size*4, '0')
  hash_bin = hash_bin.to_i(2)
  hash_bin += 1

  # y volvemos a convertir a string
  x = hash_bin.to_s(2)

  # si los b primeros bits del hash son cero, salgo del bucle
  for i in 0..bits_cero-1
    if hash_bin[i] != "0" then
      terminado = false
    end
  end
end

# salida, imprimimos contador, valor del hash y éste último en binario
puts "ID: #{id}"
puts "Cadena aleatoria X: #{x}"
puts "Número de iteraciones: #{contador}"
puts "Hash de la solución (hex): #{hash}"
