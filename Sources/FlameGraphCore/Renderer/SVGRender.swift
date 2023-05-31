import Foundation


public class SVGRender: Renderer {
    

    public static func render(graph: CallGraphNode) -> String  {
        
        
        imageheight = ((graph.maxDepth + 1) * frameheight) + ypad1 + ypad2;
        
        //package header and scripts
        var svg = header + script
        
        //package  title、details、buttons
        svg += filledRectangle(x1: 0, y1: 0, x2: Float(imagewidth), y2: Float(imageheight), fill: "url(#background)").text
        svg += stringTTF(id: "title", x: Float(imagewidth/2), y: Float(fontsize*2), str: titletext,anchor: "middle")
        svg += stringTTF(id: "details", x: Float(xpad), y: Float(imageheight)-Float(ypad2), str: " ")
        
        svg += stringTTF(id: "unzoom", x: Float(xpad), y: Float(fontsize*2), str: "Reset Zoom", extra: ["onclick":"unzoom()","style":"opacity:0.0;cursor:pointer"])
        
        svg += stringTTF(id: "search", x: Float(imagewidth - xpad - 100), y: Float(fontsize*2), str: "Search",extra: ["onmouseover":"searchover()","onmouseout":"searchout()","onclick":"search_prompt()","style":"opacity:0.1;cursor:pointer"])
        svg += stringTTF(id: "ignorecase", x: Float(imagewidth - xpad - 16), y: Float(fontsize*2), str: "ic")
        svg += stringTTF(id: "matched", x: Float(imagewidth - xpad - 100), y: Float(imageheight) - Float((ypad2 / 2)), str: " ")
        
        
        /** package <g>
         <g>
         <title> </title>
         <rect />
         <text ></text>
         </g>
         */
        for g_str in package_g(nodes: [graph]) {
            svg += g_str
        }
        
        svg += "\n </svg>"
        
        return svg
    }
    
    private static func package_g(nodes: [CallGraphNode]) -> [String] {
        
        var all_g: [String] = []
        
        
        for node in nodes {
            
            let name = formatText(text: node.symbol.name)
            let title_str = "\(name) (\(String(format:"%.2f",node.symbol.percentage))%)"

            //<title>
            let title = Element(name: "title", content: title_str)
            //<rect> attr

            
            let widthpertime = Float((imagewidth - 2 * xpad) / 100)

            var width:Float = 0
            if let parent = node.parentNode {
                
                if parent.symbol.percentage == 0 {
                    width = minwidth
                } else {
                    width = parent.width * node.symbol.percentage / parent.symbol.percentage
                }
            } else {
                width = Float(imagewidth - 2 * xpad)
            }
            
            let x1 = node.startX(uw:widthpertime)
            let x2 = x1 + width
            let y1 = Float(imageheight - (ypad2*2) - (node.symbol.depthLevel + 1) * frameheight + framepad)
            let y2 = y1 + Float(frameheight) - 1
            node.x = x1
            node.width = width
            let color = randomColor()
            
            
            let rect = filledRectangle(x1: x1, y1: y1, x2: x2, y2: y2, fill: color)

            //<text>
            let text_attr = ["x":String(format: "%.2f", x1+3), "y":String(format: "%.2f", 3+(y1+y2)/2), "font-size":String(fontsize), "font-family":String(fonttype)]
            
            let name_len = Int((Float(x2)-Float(x1))/(Float(fontsize) * Float(fontwidth)))
            var short_name = name
            
            if name_len < 3 {
                short_name = ""
            }else if name_len < name.count {
                
                let start = name.index(name.startIndex, offsetBy: name_len-2)
                
                short_name.replaceSubrange(start..<name.endIndex, with: "..")
            }
            
            let text = Element(name: "text", content: short_name, attrs:text_attr)

            //<g> attr
            let g_attr = ["class":"func_g", "onmouseover":"s('\(title_str)')", "onmouseout":"c()", "onclick":"zoom(this)"]
            let g = Element(name: "g", content: "", attrs: g_attr, subElements: [title,rect,text])
            
            
            all_g.append(g.text)
            
            all_g += package_g(nodes: node.subNodes)
        }
        
        return all_g
    }
    
    private static func filledRectangle(x1: Float, y1:Float, x2:Float, y2:Float, fill:String, extra:[String:String]? = [:]) -> EmptyElement {
        
        let w = x2 - x1
        let h = y2 - y1
        
        var attrs = ["x":String(x1), "y":String(y1), "width":String(w), "height":String(h),"fill":fill, "rx":"2","ry":"2"]
        if extra != nil && extra!.keys.count > 0 {
            attrs = attrs.merging(extra!) { (_, new) in new }
        }
        
        return EmptyElement(name: "rect", attrs: attrs)
        
    }
    
    private static func stringTTF(id: String, x:Float, y:Float, str:String, fill:String? = "rgb(0,0,0)", anchor:String? = "", extra:[String:String]? = [:]) -> String {
        
        var attrs = ["x":String(format: "%.2f", x), "y":String(y), "id":id, "font-size":String(fontsize), "font-family":String(fonttype), "fill":fill!, "text-anchor":anchor!]
        
        if extra != nil && extra!.keys.count > 0 {
            attrs = attrs.merging(extra!) { (_, new) in new }
        }
        
        return Element(name: "text", content: str, attrs: attrs).text
        
    }
    
    private static func formatText(text:String) -> String {
        
        var str = text
        str = str.replacingOccurrences(of: "&", with: "&amp;")
        str = str.replacingOccurrences(of: "<", with: "&lt;")
        str = str.replacingOccurrences(of: ">", with: "&gt;")
        str = str.replacingOccurrences(of: "\"", with: "&quot;")
        return str
    }
    
    private static func randomColor() -> String {
        
        let r = 205 + Int.random(in: 0...50)
        let g = Int.random(in: 0...230)
        let b = Int.random(in: 0...55)
        return String(format: "rgb(%d,%d,%d)", r,g,b)
    }
    
}


extension String: RenderTarget {
    public func write(to url: URL) throws {
        try write(to: url, atomically: true, encoding: .utf8)
    }
}



let fonttype = "Verdana";
let imagewidth = 1200;          // max width, pixels
var imageheight = 700;
let frameheight = 16;           // max height is dynamic
let fontsize = 12;              // base text size
let titlesize = fontsize + 5;   //
let fontwidth = 0.59;           // avg width relative to fontsize
let minwidth:Float = 0.2;             // min function width, pixels
let nametype = "Function:";     // what are the names in the data?
let countname = "samples";      // what are the counts in the data?
let colors = "hot";             // color theme
let bgcolors = "";              // background color theme
let factor = 1;                 // factor to scale counts by
let hash = 0;                   // color by function name
let palette = 0;                // if we use consistent palettes (default off)
let stackreverse = 0;           // reverse stack order, switching merge end
let inverted = 0;               // icicle graph
let flamechart = 0;             // produce a flame chart (sort by time, do not merge stacks)
let negate = 0;                 // switch differential hues
let titletext = "Flame Chart";             // centered heading
let titledefault = "Flame Graph";    // overwritten by --title
let titleinverted = "Icicle Graph";    //   "    "
let searchcolor = "rgb(230,0,230)";    // color for search highlighting
let notestext = "";        // embedded notes in SVG
let subtitletext = "";        // second level title (optional)
let help = 0;
let bgcolor1 = "#eeeeee";       // background color gradient start
let bgcolor2 = "#eeeeb0";       // background color gradient stop

let ypad1 = fontsize * 3;      // pad top, include title
let ypad2 = fontsize * 2 + 10; // pad bottom, include labels
let ypad3 = fontsize * 2;      // pad top, include subtitle (optional)
let xpad = 10;                  // pad lefm and right
let framepad = 1;        // vertical padding for frames
let depthmax = 0;


let header = """
<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg version="1.1" width="\(imagewidth)" height="\(imageheight)" onload="init(evt)" viewBox="0 0 \(imagewidth) \(imageheight)" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
"""

let script = """
<defs>
    <linearGradient id="background" y1="0" y2="1" x1="0" x2="0" >
        <stop stop-color="\(bgcolor1)" offset="5%" />
        <stop stop-color="\(bgcolor2)" offset="95%" />
    </linearGradient>
</defs>
<style type="text/css">
    .func_g:hover { stroke:black; stroke-width:0.5; cursor:pointer; }
    text { font-family:\(fonttype); font-size:\(fontsize)px; fill:#000000; }
    #search, #ignorecase { opacity:0.1; cursor:pointer; }
    #search:hover, #search.show, #ignorecase:hover, #ignorecase.show { opacity:1; }
    #subtitle { text-anchor:middle; font-color:#a0a0a0; }
    #title { text-anchor:middle; font-size:\(titlesize)px}
    #unzoom { cursor:pointer; }
    #frames > *:hover { stroke:black; stroke-width:0.5; cursor:pointer; }
    .hide { display:none; }
    .parent { opacity:0.5; }
</style>
<script type="text/ecmascript">
<![CDATA[
    "use strict";
    var details, searchbtn, unzoombtn, matchedtxt, svg, searching, currentSearchTerm, ignorecase, ignorecaseBtn;
    function init(evt) {
        details = document.getElementById("details").firstChild;
        searchbtn = document.getElementById("search");
        ignorecaseBtn = document.getElementById("ignorecase");
        unzoombtn = document.getElementById("unzoom");
        matchedtxt = document.getElementById("matched");
        svg = document.getElementsByTagName("svg")[0];
        searching = 0;
        currentSearchTerm = null;
    }

    // mouse-over for info
    function s(info) { details.nodeValue = "symbol: " + info; }
    function c() { details.nodeValue = ' '; }

    window.addEventListener("click", function(e) {
        var target = find_group(e.target);
        if (target) {
            if (target.nodeName == "a") {
                if (e.ctrlKey === false) return;
                e.preventDefault();
            }
            if (target.classList.contains("parent")) unzoom();
            zoom(target);
        }
        else if (e.target.id == "unzoom") unzoom();
        else if (e.target.id == "search") search_prompt();
        else if (e.target.id == "ignorecase") toggle_ignorecase();
    }, false)

    // ctrl-F for search
    window.addEventListener("keydown",function (e) {
        if (e.keyCode === 114 || (e.ctrlKey && e.keyCode === 70)) {
            e.preventDefault();
            search_prompt();
        }
    }, false)

    // ctrl-I to toggle case-sensitive search
    window.addEventListener("keydown",function (e) {
        if (e.ctrlKey && e.keyCode === 73) {
            e.preventDefault();
            toggle_ignorecase();
        }
    }, false)

    // functions
    function find_child(node, selector) {
        var children = node.querySelectorAll(selector);
        if (children.length) return children[0];
        return;
    }
    function find_group(node) {
        var parent = node.parentElement;
        if (!parent) return;
        if (parent.id == "frames") return node;
        return find_group(parent);
    }
    function orig_save(e, attr, val) {
        if (e.attributes["_orig_" + attr] != undefined) return;
        if (e.attributes[attr] == undefined) return;
        if (val == undefined) val = e.attributes[attr].value;
        e.setAttribute("_orig_" + attr, val);
    }
    function orig_load(e, attr) {
        if (e.attributes["_orig_"+attr] == undefined) return;
        e.attributes[attr].value = e.attributes["_orig_" + attr].value;
        e.removeAttribute("_orig_"+attr);
    }
    function g_to_text(e) {
        var text = find_child(e, "title").firstChild.nodeValue;
        return (text)
    }
    function g_to_func(e) {
        var func = g_to_text(e);
        // if there's any manipulation we want to do to the function
        // name before it's searched, do it here before returning.
        return (func);
    }
    
    function update_text(e) {
            var r = find_child(e, "rect");
            var t = find_child(e, "text");
            var w = parseFloat(r.attributes["width"].value) -3;
            var txt = find_child(e, "title").textContent.replace(/\\([^(]*\\)/,"");
            t.attributes["x"].value = parseFloat(r.attributes["x"].value) +3;
            
            // Smaller than this size won't fit anything
            if (w < 2*12*0.59) {
                t.textContent = "";
                return;
            }
            
            t.textContent = txt;
            // Fit in full text width
            if (/^ *$/.test(txt) || t.getSubStringLength(0, txt.length) < w)
                return;
            
            for (var x=txt.length-2; x>0; x--) {
                if (t.getSubStringLength(0, x+2) <= w) {
                    t.textContent = txt.substring(0,x) + "..";
                    return;
                }
            }
            t.textContent = "";
        }
        // zoom
        function zoom_reset(e) {
            if (e.attributes != undefined) {
                orig_load(e, "x");
                orig_load(e, "width");
            }
            if (e.childNodes == undefined) return;
            for(var i=0, c=e.childNodes; i<c.length; i++) {
                zoom_reset(c[i]);
            }
        }
        function zoom_child(e, x, ratio) {
            if (e.attributes != undefined) {
                if (e.attributes["x"] != undefined) {
                    orig_save(e, "x");
                    e.attributes["x"].value = (parseFloat(e.attributes["x"].value) - x - 10) * ratio + 10;
                    if(e.tagName == "text") e.attributes["x"].value = find_child(e.parentNode, "rect", "x") + 3;
                }
                if (e.attributes["width"] != undefined) {
                    orig_save(e, "width");
                    e.attributes["width"].value = parseFloat(e.attributes["width"].value) * ratio;
                }
            }
            
            if (e.childNodes == undefined) return;
            for(var i=0, c=e.childNodes; i<c.length; i++) {
                zoom_child(c[i], x-10, ratio);
            }
        }
        function zoom_parent(e) {
            if (e.attributes) {
                if (e.attributes["x"] != undefined) {
                    orig_save(e, "x");
                    e.attributes["x"].value = 10;
                }
                if (e.attributes["width"] != undefined) {
                    orig_save(e, "width");
                    e.attributes["width"].value = parseInt(svg.width.baseVal.value) - (10*2);
                }
            }
            if (e.childNodes == undefined) return;
            for(var i=0, c=e.childNodes; i<c.length; i++) {
                zoom_parent(c[i]);
            }
        }
        function zoom(node) {
            var attr = find_child(node, "rect").attributes;
            var width = parseFloat(attr["width"].value);
            var xmin = parseFloat(attr["x"].value);
            var xmax = parseFloat(xmin + width);
            var ymin = parseFloat(attr["y"].value);
            var ratio = (svg.width.baseVal.value - 2*10) / width;
            
            // XXX: Workaround for JavaScript float issues (fix me)
            var fudge = 0.0001;
            
            var unzoombtn = document.getElementById("unzoom");
            unzoombtn.style["opacity"] = "1.0";
            
            var el = document.getElementsByTagName("g");
            for(var i=0;i<el.length;i++){
                var e = el[i];
                var a = find_child(e, "rect").attributes;
                var ex = parseFloat(a["x"].value);
                var ew = parseFloat(a["width"].value);
                // Is it an ancestor
                if (0 == 0) {
                    var upstack = parseFloat(a["y"].value) > ymin;
                } else {
                    var upstack = parseFloat(a["y"].value) < ymin;
                }
                if (upstack) {
                    // Direct ancestor
                    if (ex <= xmin && (ex+ew+fudge) >= xmax) {
                        e.style["opacity"] = "0.5";
                        zoom_parent(e);
                        e.onclick = function(e){unzoom(); zoom(this);};
                        update_text(e);
                    }
                    // not in current path
                    else
                        e.style["display"] = "none";
                }
                // Children maybe
                else {
                    // no common path
                    if (ex < xmin || ex + fudge >= xmax) {
                        e.style["display"] = "none";
                    }
                    else {
                        zoom_child(e, xmin, ratio);
                        e.onclick = function(e){zoom(this);};
                        update_text(e);
                    }
                }
            }
        }
        function unzoom() {
            var unzoombtn = document.getElementById("unzoom");
            unzoombtn.style["opacity"] = "0.0";
            
            var el = document.getElementsByTagName("g");
            for(var i=0;i<el.length;i++) {
                el[i].style["display"] = "block";
                el[i].style["opacity"] = "1";
                zoom_reset(el[i]);
                update_text(el[i]);
            }
        }

]]>
</script> \n
"""



