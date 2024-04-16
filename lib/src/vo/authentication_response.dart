

class AuthenticationResponse{
  final String flag;
  final String? similarity;
  final String sn;
  final String signs;

  AuthenticationResponse({
    required this.flag,
    this.similarity,
    required this.sn,
    required this.signs
}) {
    assert(
    flag.isNotEmpty,
    '''
Cannot pass an empty flag.
      ''',
    );
    assert(sn.isNotEmpty,'''
Cannot pass an empty sn.
      ''');
    assert(signs.isNotEmpty,'''
Cannot pass an empty signs.
      ''');
  }

}