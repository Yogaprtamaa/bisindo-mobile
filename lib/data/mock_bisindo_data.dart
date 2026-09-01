class MockDetection {
  final String tag;
  final double conf;
  /// Normalized box [x1, y1, x2, y2] range 0.0 - 1.0 relative to preview
  final List<double> box;

  const MockDetection({
    required this.tag,
    required this.conf,
    required this.box,
  });

  Map<String, dynamic> toMap() => {
        "tag": tag,
        "box": [...box, conf],
      };
}

class MockBisindoData {
  // ALPHABET MODE: hanya huruf single (A-Z)
  static const List<List<MockDetection>> alphabetScenarios = [
    // Scenario 0: Single A - center
    [
      MockDetection(tag: "A", conf: 0.92, box: [0.28, 0.22, 0.72, 0.78]),
    ],
    // Scenario 1: B dominan + C kecil (NMS demo)
    [
      MockDetection(tag: "B", conf: 0.88, box: [0.22, 0.18, 0.68, 0.82]),
      MockDetection(tag: "C", conf: 0.62, box: [0.55, 0.30, 0.85, 0.65]),
    ],
    // Scenario 2: H
    [
      MockDetection(tag: "H", conf: 0.76, box: [0.30, 0.25, 0.75, 0.75]),
    ],
    // Scenario 3: Searching / empty
    [],
    // Scenario 4: Multiple huruf berjajar (S, T)
    [
      MockDetection(tag: "S", conf: 0.81, box: [0.15, 0.20, 0.45, 0.70]),
      MockDetection(tag: "T", conf: 0.79, box: [0.55, 0.22, 0.85, 0.72]),
    ],
  ];

  // KATA MODE: kata panjang >1 huruf
  static const List<List<MockDetection>> wordScenarios = [
    // Scenario 0: Aku
    [
      MockDetection(tag: "Aku", conf: 0.91, box: [0.25, 0.20, 0.75, 0.80]),
    ],
    // Scenario 1: Kamu + overlap Maaf
    [
      MockDetection(tag: "Kamu", conf: 0.84, box: [0.20, 0.18, 0.70, 0.75]),
      MockDetection(tag: "Maaf", conf: 0.68, box: [0.50, 0.35, 0.88, 0.70]),
    ],
    // Scenario 2: Senang
    [
      MockDetection(tag: "Senang", conf: 0.77, box: [0.28, 0.22, 0.80, 0.78]),
    ],
    // Scenario 3: empty searching
    [],
    // Scenario 4: Bantu - Sabar
    [
      MockDetection(tag: "Bantu", conf: 0.86, box: [0.18, 0.20, 0.52, 0.72]),
      MockDetection(tag: "Sabar", conf: 0.74, box: [0.58, 0.24, 0.90, 0.68]),
    ],
  ];

  static List<String> get allAlphabetLabels => [
        "A","B","C","D","E","F","G","H","I","J","K","L","M",
        "N","O","P","Q","R","S","T","U","V","W","X","Y","Z"
      ];

  static List<String> get allWordLabels => [
        "Aku","Apa","Ayah","Baik","Bantu","Bermain","Dia","Jangan",
        "Kakak","Kamu","Kapan","Keren","Kerja","Maaf","Marah","Minum",
        "Rumah","Sabar","Sedih","Senang","Suka"
      ];
}
