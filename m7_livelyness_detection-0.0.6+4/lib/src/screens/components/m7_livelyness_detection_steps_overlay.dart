import 'package:m7_livelyness_detection/index.dart';

class M7LivelynessDetectionStepOverlay extends StatefulWidget {
  final List<M7LivelynessStepItem> steps;
  final VoidCallback onCompleted;
  final String? hintMessage;
  bool alreadyOnComplete = false;
  M7LivelynessDetectionStepOverlay(
      {Key? key,
      required this.steps,
      required this.onCompleted,
      required this.hintMessage})
      : super(key: key);

  @override
  State<M7LivelynessDetectionStepOverlay> createState() =>
      M7LivelynessDetectionStepOverlayState();
}

class M7LivelynessDetectionStepOverlayState
    extends State<M7LivelynessDetectionStepOverlay>
    with SingleTickerProviderStateMixin {
  //* MARK: - Public Variables
  //? =========================================================
  int get currentIndex {
    return _currentIndex;
  }

  bool _isLoading = false;

  //* MARK: - Private Variables
  //? =========================================================
  int _currentIndex = 0;

  late final PageController _pageController;

  //* MARK: - Life Cycle Methods
  //? =========================================================
  @override
  void initState() {
    _pageController = PageController(
      initialPage: 0,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      width: 500,
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildBody(),
          Align(
            alignment: Alignment(0.0, 1 / 3),
            child: Text(
              widget.hintMessage ?? '请将脸部对正框内,确保光线充足\n您正在使用联行支付,进行人脸验证',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
              ),
            ),
          ),
          // Visibility(
          //   visible: _isLoading,
          //   child: const Center(
          //     child: CircularProgressIndicator.adaptive(),
          //   ),
          // ),
        ],
      ),
    );
  }

  //* MARK: - Public Methods for Business Logic
  //? =========================================================
  Future<void> nextPage() async {
    print("${DateTime.now()}, nextPage _isLoading $_isLoading");
    if (_isLoading) {
      return;
    }
    print(
        "${DateTime.now()}, nextPage alreadyOnComplete ${widget.alreadyOnComplete}, _currentIndex ${_currentIndex}, ${widget.steps.length}");
    if ((_currentIndex + 1) <= (widget.steps.length - 1)) {
      //Move to next step
      _showLoader();
      await Future.delayed(
        const Duration(
          milliseconds: 500,
        ),
      );
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
      await Future.delayed(
        // const Duration(seconds: 1),
        const Duration(milliseconds: 500),
      );
      _hideLoader();
      setState(() => _currentIndex++);
    } else {
      if (widget.alreadyOnComplete == false) {
        widget.alreadyOnComplete = true;
        widget.onCompleted();
      }
    }
  }

  void reset() {
    _pageController.jumpToPage(0);
    setState(() => _currentIndex = 0);
  }

  //* MARK: - Private Methods for Business Logic
  //? =========================================================
  void _showLoader() => setState(
        () => _isLoading = true,
      );

  void _hideLoader() => setState(
        () => _isLoading = false,
      );

  //* MARK: - Private Methods for UI Components
  //? =========================================================
  Widget _buildBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // SizedBox(
        //   height: 10,
        //   width: double.infinity,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.start,
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       Expanded(
        //         flex: _currentIndex + 1,
        //         child: Container(
        //           decoration: BoxDecoration(
        //             borderRadius: const BorderRadius.only(
        //               topRight: Radius.circular(20),
        //               bottomRight: Radius.circular(20),
        //             ),
        //             color: Colors.green.shade800,
        //           ),
        //         ),
        //       ),
        //       Expanded(
        //         flex: widget.steps.length - (_currentIndex + 1),
        //         child: Container(
        //           color: Colors.transparent,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        const Spacer(),
        Flexible(
          flex: 2,
          child: AbsorbPointer(
            absorbing: true,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.steps.length,
              itemBuilder: (context, index) {
                return _buildAnimatedWidget(
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Container(
                      // decoration: BoxDecoration(
                      //   color: Colors.white,
                      //   borderRadius: BorderRadius.circular(20),
                      //   boxShadow: const [
                      //     BoxShadow(
                      //       blurRadius: 5,
                      //       spreadRadius: 2.5,
                      //       color: Colors.black12,
                      //     ),
                      //   ],
                      // ),
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        widget.steps[index].title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  isExiting: index != _currentIndex,
                );
              },
            ),
          ),
        ),
        const Spacer(
          flex: 14,
        ),
      ],
    );
  }

  Widget _buildAnimatedWidget(
    Widget child, {
    required bool isExiting,
  }) {
    return isExiting
        ? ZoomOut(
            animate: true,
            child: FadeOutLeft(
              animate: true,
              delay: const Duration(milliseconds: 200),
              child: child,
            ),
          )
        : ZoomIn(
            animate: true,
            delay: const Duration(milliseconds: 500),
            child: FadeInRight(
              animate: true,
              delay: const Duration(milliseconds: 700),
              child: child,
            ),
          );
  }
}

//* MARK: - add
//? =========================================================
// 绘制带有圆形孔洞的遮罩
// class HolePainterWidget extends StatelessWidget {
//   final Animation<double> animation;
//
//   const HolePainterWidget({Key? key, required this.animation}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return ClipOval(
//       child: AspectRatio(
//         aspectRatio: 2.0,
//         child: Container(
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//             color: Colors.red.withOpacity(0.5),
//           ),
//           // child: AnimatedBuilder(
//           //   animation: animation,
//           //   builder: (context, child) {
//           //     return CustomPaint(
//           //       size: Size.infinite,
//           //       painter: HolePainter(animation.value),
//           //     );
//           //   },
//           // ),
//         ),
//       ),
//     );
//   }
// }

// 自定义绘制器，用于绘制圆形孔洞和动态效果
class HolePainter extends CustomPainter {
  final double radiusFraction;

  HolePainter(this.radiusFraction);

  @override
  void paint(Canvas canvas, Size size) {
    // 计算圆心位置和半径
    final center = size.center(Offset.zero);
    final radius = size.width * 0.3 * radiusFraction; // 可以调整半径比例

    // 绘制遮罩
    final paint = Paint()..blendMode = BlendMode.clear;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
