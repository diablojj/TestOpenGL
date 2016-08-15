//attribute vec4 vertexIn;
//attribute vec2 textureIn;
//varying vec2 textureOut;
//void main(void)
//{
//    gl_Position = vertexIn;
//    textureOut = textureIn;
//}

attribute vec4 Position; // 1
attribute vec4 SourceColor; // 2

varying vec4 DestinationColor; // 3

void main(void) { // 4
    DestinationColor = SourceColor; // 5
    gl_Position = Position; // 6
}