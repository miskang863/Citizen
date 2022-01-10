class MyHelsinkiEventsItem {
  final String name;
  final double lat;
  final double lon;
  final String desc;
  final String descBody;
  final List imageUrlList;
  final String infoUrl;
  final address;
  final tags;
  final String itemID;
  final String startTime;
  final String endTime;
  final int travelTime;

  MyHelsinkiEventsItem(
      this.name,
      this.lat,
      this.lon,
      this.desc,
      this.descBody,
      this.imageUrlList,
      this.infoUrl,
      this.address,
      this.tags,
      this.itemID,
      this.startTime,
      this.endTime,
      this.travelTime);
}
