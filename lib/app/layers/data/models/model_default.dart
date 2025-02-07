class ModelDefaultData {
  String? descricao;
  int? total;
  double? porcentagem;

  ModelDefaultData({
    this.descricao,
    this.total,
    this.porcentagem,
  });
  ModelDefaultData.fromJson(Map<String, dynamic> json) {
    descricao = json['descricao']?.toString();
    total = json['total']?.toInt();
    porcentagem = json['porcentagem']?.toDouble();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['descricao'] = descricao;
    data['total'] = total;
    data['porcentagem'] = porcentagem;
    return data;
  }
}

class ModelDefault {
  bool? success;
  int? qtdregistros;
  double? vlrtotalgeral;
  List<ModelDefaultData?>? data;

  ModelDefault({
    this.success,
    this.data,
  });
  ModelDefault.fromJson(Map<String, dynamic> json) {
    success = json['success'];

    if (json.containsKey('qtdregistros')) {
      qtdregistros = json['qtdregistros'] ?? 0;
    }

    if (json.containsKey('vlrtotalgeral')) {
      vlrtotalgeral = double.parse(json['vlrtotalgeral'].toString());
    }

    if (json['data'] != null) {
      final v = json['data'];
      final arr0 = <ModelDefaultData>[];
      v.forEach((v) {
        arr0.add(ModelDefaultData.fromJson(v));
      });
      data = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['success'] = success;
    data['qtdregistros'] = qtdregistros;
    data['vlrtotalgeral'] = vlrtotalgeral;
    if (this.data != null) {
      final v = this.data;
      final arr0 = [];
      for (var v in v!) {
        arr0.add(v!.toJson());
      }
      data['data'] = arr0;
    }
    return data;
  }
}
