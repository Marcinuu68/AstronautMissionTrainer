extends Label

var czas_gry: float = 0.0
var timer_aktualizacji: float = 0.0

# Początkowe wartości parametrów
var tlen: float = 20.9
var cisnienie: float = 101.3
var temperatura: float = 21.5

func _process(delta: float) -> void:
	czas_gry += delta
	timer_aktualizacji += delta
	
	# Zmienia losowe parametry co 1.5 sekundy, żeby wyglądało to naturalnie
	if timer_aktualizacji >= 1.5:
		timer_aktualizacji = 0.0
		tlen = randf_range(20.5, 21.1)
		cisnienie = randf_range(100.5, 101.9)
		temperatura = randf_range(21.0, 22.2)

	# Składanie tekstu z nowymi liniami (\n) na końcu każdego wiersza
	text = "SYSTEMY: SPRAWNE\n" \
		 + "CZAS MISJI: " + str(int(czas_gry)) + "s\n" \
		 + "TLEN: " + String.num(tlen, 1) + "%\n" \
		 + "CISNIENIE: " + String.num(cisnienie, 1) + " kPa\n" \
		 + "TEMPERATURA: " + String.num(temperatura, 1) + " C"
