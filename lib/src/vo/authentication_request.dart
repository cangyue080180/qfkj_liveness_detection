

class ComparisonRequest{
  final String id;
  final String name;
  final String data;

  ComparisonRequest({
    required this.id,
    required this.name,
    required this.data
}){
    assert(
    id.isNotEmpty,
    '''
Cannot pass an empty id.
      ''',
    );
    assert(name.isNotEmpty,'''
Cannot pass an empty name.
      ''');
    assert(data.isNotEmpty,'''
Cannot pass an empty photo.
      ''');
  }

  factory ComparisonRequest.fromJsonForPhoto(Map<String, dynamic> json) {
    return ComparisonRequest(
      id: json['id'],
      name: json['name'],
      data: json['photo'],
    );
  }

  factory ComparisonRequest.fromJsonForVideo(Map<String, dynamic> json) {
    return ComparisonRequest(
      id: json['id'],
      name: json['name'],
      data: json['video'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'name': name,
      'photo': data,
    };
  }

  Map<String, dynamic> toJsonForVideo() {
    return {
      'ID': id,
      'name': name,
      'video': data,
    };
  }

}