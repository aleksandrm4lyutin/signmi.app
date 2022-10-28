///Класс предназначенный для показа краткой информации о карточке в коллекции

class ShortCardCollect {

  String cid; /// ID карточки
  String link; /// Ссылка
  String globalTitle; /// Название
  String author; /// Автор указанный в карточке
  String imgUrl; /// Ссылка на изображение
  int lastEdit; /// Дата и время последнего изменения
  bool private; /// Флаг закрытая карточка или нет
  bool selected; /// Локальная переменная для экрана коллекции, не загружается в облако
  bool updated; /// Локальная переменная о том, что карточка недавно редактировалась, не загружается в облако

  ShortCardCollect({
    required this.cid,
    required this.link,
    required this.globalTitle,
    required this.author,
    required this.imgUrl,
    required this.lastEdit,
    required this.private,
    required this.selected,
    required this.updated
  });

}