class PUBGUser {
  String? accountId;
  String? name;
  String? profileImage;
  String? soloTier;
  String? soloRank;
  int? soloPoints;
  String? squadTier;
  String? squadRank;
  int? squadPoints;
  String? server;

  PUBGUser(
      {this.accountId,
      this.name,
      this.profileImage,
      this.soloTier,
      this.soloRank,
      this.soloPoints,
      this.squadTier,
      this.squadRank,
      this.squadPoints,
      this.server});

  @override
  String toString() {
    return "USER INFO:\n[name: $name\naccountId: $accountId\nsoloTier: $soloTier\nsoloRank: $soloRank\nsoloPoints: $soloPoints\nsquadTier: $squadTier\nsquadRank: $squadRank\nrankPoints: $squadPoints";
  }

  factory PUBGUser.fromJson(List userInfo, Map<String, dynamic> rankData,
      String? profileImage, String server) {
    if (rankData["solo"] != null) {
      if (rankData["squad"] != null) {
        return PUBGUser(
          accountId: userInfo.first["id"],
          name: userInfo.first["attributes"]["name"],
          profileImage: profileImage,
          soloTier: rankData["solo"]["currentTier"]["tier"],
          soloRank: rankData["solo"]["currentTier"]["subTier"],
          soloPoints: rankData["solo"]["currentRankPoint"],
          squadTier: rankData["squad"]["currentTier"]["tier"],
          squadRank: rankData["squad"]["currentTier"]["subTier"],
          squadPoints: rankData["squad"]["currentRankPoint"],
          server: server,
        );
      } else {
        return PUBGUser(
          accountId: userInfo.first["id"],
          name: userInfo.first["attributes"]["name"],
          profileImage: profileImage,
          soloTier: rankData["solo"]["currentTier"]["tier"],
          soloRank: rankData["solo"]["currentTier"]["subTier"],
          soloPoints: rankData["solo"]["currentRankPoint"],
          server: server,
        );
      }
    } else if (rankData["squad"] != null) {
      return PUBGUser(
        accountId: userInfo.first["id"],
        name: userInfo.first["attributes"]["name"],
        profileImage: profileImage,
        squadTier: rankData["squad"]["currentTier"]["tier"],
        squadRank: rankData["squad"]["currentTier"]["subTier"],
        squadPoints: rankData["squad"]["currentRankPoint"],
        server: server,
      );
    } else if (rankData.isEmpty) {
      return PUBGUser(
        accountId: userInfo.first["id"],
        name: userInfo.first["attributes"]["name"],
        profileImage: profileImage,
        server: server,
      );
    } else
      return PUBGUser();
  }
}
