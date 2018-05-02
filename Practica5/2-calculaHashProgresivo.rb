#!/usr/bin/ruby
require 'digest'
require 'securerandom'

n = 256

print "Introduce el texto: "
texto = gets.chomp

# buscar una cadena aleatoria de n bits (en hex, n/4)
nonce = SecureRandom.hex(n/4)

# concatenarle el texto, y guardar como id
id = nonce + texto

# empiezo bucle, busco otra cadena aleatoria de n bits
hash = ""

puts "ID: #{id}"

# vamos a contar desde 1 cero hasta 15
for bits_cero in 1..15
  # vamos a hacer 10 experimentos para cada valor de bits_cero
  media = 0
  for i in 1..10
    contador = 0
    terminado = false
    while not terminado do
      terminado = true
      contador += 1

      x = SecureRandom.hex(n/4)

      # la concateno al id, y le aplico el hash
      aux = id + x
      hash = Digest::SHA256.hexdigest aux

      # convertimos el hash de hex a bin para buscar los ceros
      hash_bin = hash.hex.to_s(2).rjust(hash.size*4, '0')

      # si los b primeros bits del hash son cero, salgo del bucle
      for j in 0..bits_cero-1
        if hash_bin[j] != "0" then
          terminado = false
        end
      end
    end
    media += contador
  end
  media /= 10
  puts "Media de iteraciones para b=#{bits_cero} --> #{media}"
  puts " -> Hash de la solución (hex): #{hash}"
  puts " -> Cadena aleatoria X: #{x}"
end
