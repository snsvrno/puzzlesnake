package tools;

class Colors {
    static public function invertVector(v : h3d.Vector) : h3d.Vector {
        return new h3d.Vector(1 - v.x, 1 - v.y, 1 - v.z, v.w);
    }

    static public function grayScale(color : Int) : Int {

        var a = (color >> 24) & 0xff;
        var r = (color >> 16) & 0xff;
        var g = (color >> 8) & 0xff;
        var b = color & 0xff;

        // https://www.dynamsoft.com/blog/insights/image-processing/image-processing-101-color-space-conversion/
        // YUV colors
        var y = Math.floor(0.299 * r + 0.587 * g + 0.114 * b);

        return (a << 24) | (y << 16) | (y << 8) | y;
    }
}