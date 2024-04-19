
class ComparisonVideoRequest{
  final String id;
  final String name;
  final String video;

  ComparisonVideoRequest({
    required this.id,
    required this.name,
    required this.video
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
    assert(video.isNotEmpty,'''
Cannot pass an empty video.
      ''');
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'name': name,
      'video': video,
    };
  }

}