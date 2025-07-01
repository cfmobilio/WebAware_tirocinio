import '../../../models/insight_model.dart';

class InsightViewModel {
  static final Map<String, Insight> approfondimenti = {
    "privacy": Insight(titolo: "Privacy Online", descrizione: "Testo sull’importanza della privacy..."),
    "phishing": Insight(titolo: "Phishing", descrizione: "Testo per riconoscere email false..."),
    // ...
  };
}
