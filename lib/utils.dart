class Utils {
  static String getAnalyticsAffiliationBusinessSearchQuery(List<int> subEntities, int currentBusinessId) {
    var businessIds = """
      (
      SELECT _business.id
      FROM _business
      WHERE _business.id = $currentBusinessId
      )
    """;

    if (subEntities.isNotEmpty) {
      var ids = "(";
      subEntities.asMap().forEach((index, value) {
        ids += "$value";
        if (index < subEntities.length - 1) {
          ids += ",";
        }
      });
      ids += ")";
      businessIds = """
      (
      SELECT _business.id
      FROM _business
      WHERE _business.id IN $ids
      AND _business.parent_id = $currentBusinessId
      OR _business.id = $currentBusinessId
      )
      """;
    }

    return businessIds;
  }
}
