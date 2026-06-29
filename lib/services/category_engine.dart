
class CategoryEngine {
  static String detect(String text) {
    final t = text.toLowerCase();

    if (t.contains("food") || t.contains("lunch")) return "Food";
    if (t.contains("diesel") || t.contains("truck")) return "Transport";
    if (t.contains("repair") || t.contains("pipe")) return "Maintenance";
    if (t.contains("electric") || t.contains("gas")) return "Energy";

    return "Misc";
  }
}
