import QtQuick

// Runs against the real BarWidget.qml and Panel.qml through tests/run.sh.
// `h` is the harness (tests/harness/Harness.qml); a test that has to wait is
// a generator and yields the number of milliseconds to wait.
Item {
    id: spec

    property var h: null

    function fileOf(image) {
        return String(image.source).split("/").pop();
    }

    // --- Layout ------------------------------------------------------------

    // Regression: the widget was 2px taller than the bar, which made its
    // whole bar section taller and shifted every neighbouring widget.
    function test_theWidgetIsExactlyAsTallAsTheBar() {
        var w = h.createWidget({
        });
        h.compare(w.implicitHeight, h.bar.barSize);
        h.verify(h.byName("animation").height <= h.bar.barSize, "the animation fits inside the bar");
    }

    // --- Animation choice --------------------------------------------------

    function* test_catjamIsTheDefault() {
        var w = h.createWidget({
        });
        yield 50;
        h.compare(w.currentGif, "catjam.gif");
        h.compare(h.byName("animation").status, Image.Ready);
    }

    function* test_everyBundledAnimationLoads() {
        var w = h.createWidget({
        });
        var image = h.byName("animation");
        for (var i = 0; i < w.gifOptions.length; i++) {
            w.settings = {
                "gif": w.gifOptions[i].value
            };
            yield 50;
            h.compare(fileOf(image), w.gifOptions[i].value);
            h.compare(image.status, Image.Ready, w.gifOptions[i].label);
        }
    }

    // Regression: the setting went straight into the image source, so a
    // stale name blanked the widget and a path or URL was read or fetched.
    function* test_anythingButABundledAnimationFallsBackToCatjam() {
        var w = h.createWidget({
        });
        var image = h.byName("animation");
        var unknown = ["gone.gif", "../../../../etc/passwd", "/etc/passwd", "http://127.0.0.1:1/tracker.gif", "", 42];
        for (var i = 0; i < unknown.length; i++) {
            w.settings = {
                "gif": unknown[i]
            };
            yield 50;
            h.compare(w.currentGif, "catjam.gif", String(unknown[i]));
            h.compare(fileOf(image), "catjam.gif", String(unknown[i]));
            h.compare(image.status, Image.Ready, String(unknown[i]));
        }
    }

    function* test_pickingAnAnimationPersistsIt() {
        var w = h.createWidget({
            "gif": "catjam.gif"
        });
        yield 50;
        w.open();
        yield 50;
        h.byName("animationPicker").changed("parrot.gif");
        yield 50;
        h.compare(h.lastPersisted(), {
            "id": "no.koka.cpu-catjam",
            "gif": "parrot.gif"
        });
        h.compare(w.currentGif, "parrot.gif");
        h.compare(fileOf(h.byName("animation")), "parrot.gif");
    }

    function* test_changeGifNeverPersistsAnUnknownFile() {
        var w = h.createWidget({
            "gif": "parrot.gif"
        });
        yield 50;
        w.changeGif("http://127.0.0.1:1/tracker.gif");
        yield 50;
        h.compare(h.lastPersisted().gif, "catjam.gif");
    }

    function* test_clickingATilePicksThatAnimation() {
        var w = h.createWidget({
        });
        yield 50;
        w.open();
        yield 50;
        h.compare(h.byName("animationName").text, "Catjam");
        h.click(h.byName("animationTile-nyancat.gif"));
        yield 50;
        h.compare(h.lastPersisted().gif, "nyancat.gif");
        h.compare(w.currentGif, "nyancat.gif");
        h.compare(h.byName("animationPicker").value, "nyancat.gif");
    }

    // --- CPU ---------------------------------------------------------------

    function test_speedFollowsCpuUsage() {
        var w = h.createWidget({
        });
        var image = h.byName("animation");
        w.cpuPercent = 0;
        h.compare(image.speed, 0.5);
        w.cpuPercent = 50;
        h.compare(image.speed, 1.75);
        w.cpuPercent = 100;
        h.compare(image.speed, 3);
    }

    function* test_cpuUsageIsSampled() {
        var w = h.createWidget({
        });
        w.cpuPercent = -1;
        yield 1600;
        h.verify(w.cpuPercent >= 0 && w.cpuPercent <= 100, "vmstat sample in range, got " + w.cpuPercent);
        w.open();
        yield 50;
        h.compare(h.byName("cpuCatjamPanel").cpuPercent, w.cpuPercent, "the panel shows the same reading");
    }

    function* test_theCardShowsTheLoad() {
        var w = h.createWidget({
        });
        yield 50;
        w.open();
        yield 50;
        var panel = h.byName("cpuCatjamPanel");
        var card = h.byName("usageCard");
        panel.cpuPercent = 5;
        h.compare(card.value + card.unit, "5.0%");
        h.compare(card.detail, "Chill vibes");
        h.compare(card.note, "0.63\u00d7 speed");
        h.compare(card.progress, 0.05);
        h.compare(h.byName("titleCaption").text, "Your CPU is at 5%");
        panel.cpuPercent = 45;
        h.compare(card.detail, "Getting into it");
        panel.cpuPercent = 100;
        h.compare(card.detail, "Maximum overdrive");
        h.compare(card.note, "3.00\u00d7 speed");
        h.compare(card.progress, 1);
    }

    function* test_thePanelOpensAndCloses() {
        var w = h.createWidget({
        });
        yield 50;
        h.compare(w.opened, false);
        w.toggle();
        yield 50;
        h.compare(w.opened, true);
        h.key(Qt.Key_Escape);
        yield 50;
        h.compare(w.opened, false);
    }

}
