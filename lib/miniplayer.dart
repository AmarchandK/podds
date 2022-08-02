import 'package:flutter/material.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedContainer(
        duration: const Duration(seconds: 1),
        child: SizedBox(
          height: 61,
          child: Column(
            children: [
              SizedBox(
                height: 1,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackShape: SpotifyMiniPlayerTrackShape(),
                    trackHeight: 1,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 2,
                    ),
                  ),
                  child: const Slider(
                    value: 70,
                    max: 100,
                    onChanged: null,
                  ),
                ),
              ),
              Row(
                children: [
                  Flexible(
                    flex: 8,
                    child: GestureDetector(
                      child: Row(
                        children: [
                          Flexible(
                              child: Center(
                            child: Image.asset(
                              'assets/1-removebg-preview.png',
                              height: 50,
                              width: 70,
                            ),
                          )),
                          const Flexible(
                            flex: 3,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text('Song Name'),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const Flexible(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.only(right: 15.0),
                        child: SizedBox(
                          height: 60,
                          width: 60,
                          child: IconButton(
                            icon: Icon(Icons.pause),
                            onPressed: null,
                          ),
                        ),
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    ));
  }
}

class SpotifyMiniPlayerTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    @required RenderBox? parentBox,
    Offset offset = Offset.zero,
    @required SliderThemeData? sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme?.trackHeight as double;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox!.size.height - trackHeight) / 2;
    final trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
