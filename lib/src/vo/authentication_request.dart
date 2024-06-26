

class ComparisonRequest{
  final String id;
  final String name;
  final String photo;

  ComparisonRequest({
    required this.id,
    required this.name,
    required this.photo
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
    assert(photo.isNotEmpty,'''
Cannot pass an empty photo.
      ''');
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'name': name,
      'photo': photo,
    };
  }

}