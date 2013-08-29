function graphDonutOne(percentage,id)
{
    var canvasid = id + "_canvas";
    document.getElementById(id).innerHTML = "<canvas id='" + canvasid + "' width='150px' height='150px'></canvas>";
    donutone(75,75,75,20,percentage,0,canvasid);
}

function graphDonutTwo(percentage1,percentage2,id)
{
    var canvasid = id + "_canvas";
    document.getElementById(id).innerHTML = "<canvas id='" + canvasid + "' width='150px' height='150px'></canvas>";
    donuttwo(75,75,75,20,percentage1,percentage2,0,canvasid);
}

function donutone(x, y, radius, thickness, percentage, offset, id) {
    var canvas = document.getElementById(id);
    drawDonut(x, y, radius, thickness, 1, offset, canvas, "#f5f5f5");
    drawDonut(x, y, radius, thickness, percentage, offset, canvas, "#274d9b");
    drawText(x+5,y+10,percentage*100 + "%",canvas);
}

function donuttwo(x,y,radius,thickness,percentage1,percentage2,offset,id){
    var canvas = document.getElementById(id);
    drawDonut(x, y, radius, thickness, 1, offset, canvas, "#f5f5f5");
    drawDonut(x, y, radius, thickness, percentage1, offset, canvas, "#274d9b");
    drawText(x+5,y-5,percentage1*100 + "%",canvas);
    drawDonut(x, y, radius, thickness, percentage2, offset+percentage1, canvas, "E8A627");
    drawText(x+5,y+25,percentage2*100 + "%",canvas);
}

function drawDonut(x, y, radius, thickness, percentage, offset, canvas, color) {
    offset = offset - 0.25;
    var context = canvas.getContext('2d');
    var startAngle = 0 + (2 * offset * Math.PI);
    var endAngle = 2 * Math.PI * percentage + (offset * Math.PI * 2);

    context.beginPath();
    var point = getPoint(x, y, radius, startAngle);
    var ipoint = getPoint(x, y, radius - thickness, startAngle);
    context.moveTo(ipoint[0], ipoint[1]);
    context.lineTo(point[0], point[1]);
    context.arc(x, y, radius, startAngle, endAngle, 0);
    point = getPoint(x, y, radius, endAngle);
    ipoint = getPoint(x, y, radius - thickness, endAngle);
    context.moveTo(point[0], point[1]);
    context.lineTo(ipoint[0], ipoint[1]);
    context.arc(x, y, radius - thickness, endAngle, startAngle, 1);
    context.fillStyle = color;
    context.fill();
}

function getPoint(x, y, radius, angle) {
    return [x + radius * Math.cos(angle), y + radius * Math.sin(angle)];
}

function drawText(x, y, text, canvas) {
    var context = canvas.getContext('2d');
    context.font = "lighter 30px sans-serif";
    context.textAlign = 'center';
    context.fillText(text, x, y);
}