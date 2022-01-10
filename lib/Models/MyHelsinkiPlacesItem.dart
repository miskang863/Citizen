class MyHelsinkiPlacesItem {
  final String name;
  final double lat;
  final double lon;
  final String desc;
  final List imageUrlList;
  final String infoUrl;
  final address;
  final tags;
  final openingHours;
  final int travelTime;
  final String itemID;

  MyHelsinkiPlacesItem(
      this.name,
      this.lat,
      this.lon,
      this.desc,
      this.imageUrlList,
      this.infoUrl,
      this.address,
      this.tags,
      this.openingHours,
      this.travelTime,
      this.itemID);
}
