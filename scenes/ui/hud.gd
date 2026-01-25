extends Control

const owlet_sprites = preload("uid://cedyrtuag5yu");
const bunny_sprites = preload("uid://qbycopj8sitg");
const seal_sprites = preload("uid://db6y45q0b7kde");

func _ready() -> void:
  match(Global.p1_char_display):
    Enums.CHARS.OWLET:
      $P1Health/P1Char.texture = owlet_sprites;
    Enums.CHARS.BUNNY:
      $P1Health/P1Char.texture = bunny_sprites;
    Enums.CHARS.SEAL:
      $P1Health/P1Char.texture = seal_sprites;
  
  match(Global.p2_char_display):
    Enums.CHARS.OWLET:
      $P2Health/P2Char.texture = owlet_sprites;
    Enums.CHARS.BUNNY:
      $P2Health/P2Char.texture = bunny_sprites;
    Enums.CHARS.SEAL:
      $P2Health/P2Char.texture = seal_sprites;
  # end match
# end _ready

func _process(_delta: float) -> void:
  $Label.text = str(CharStats.CURRENT_MONEY);
