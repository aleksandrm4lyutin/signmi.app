/// Класс предназначенный для хранения всей информации карточки и показа на экране просмотра

class PublicCard {

  String owner; /// Никнейм владельца
  String author; /// Автор указанный в карточке
  String cid; /// ID карточки
  //String link;
  String globalTitle; /// Название карточки
  String imgUrl; /// Ссылка на изображение
  List<Map> fields; /// Лист с данными полей информации, генерируется в DataService
  bool private; /// Закрытая или нет
  int lastEdit; /// Дата последнего изменения
  int origin; /// Дата создания


  PublicCard({
    required this.owner,
    required this.author,
    required this.cid,
    required this.globalTitle,
    required this.imgUrl,
    required this.fields,
    required this.private,
    required this.lastEdit,
    required this.origin });

}