//
// A NumberAnimation preset to one of the M3 motion tokens.
//
// Usage: `Anim { type: Anim.Emphasized }`. Defaults to the expressive default
// spatial curve, which is what most movement in the shell uses.
//
import QtQuick
import qs.config

NumberAnimation {
    id: root

    enum Type {
        StandardSmall = 0,
        Standard,
        StandardLarge,
        StandardExtraLarge,
        EmphasizedSmall,
        Emphasized,
        EmphasizedLarge,
        EmphasizedExtraLarge,
        FastSpatial,
        DefaultSpatial,
        SlowSpatial,
        FastEffects,
        DefaultEffects,
        SlowEffects
    }

    property int type: Anim.DefaultSpatial

    duration: {
        const d = Appearance.anim.durations;

        switch (type) {
        case Anim.FastSpatial:
            return d.expressiveFastSpatial;
        case Anim.DefaultSpatial:
            return d.expressiveDefaultSpatial;
        case Anim.SlowSpatial:
            return d.expressiveSlowSpatial;
        case Anim.FastEffects:
            return d.expressiveFastEffects;
        case Anim.DefaultEffects:
            return d.expressiveDefaultEffects;
        case Anim.SlowEffects:
            return d.expressiveSlowEffects;
        }

        // 0-7 are the four standard sizes, twice (standard then emphasized)
        return [d.small, d.normal, d.large, d.extraLarge][type % 4] ?? d.normal;
    }

    easing.type: Easing.BezierSpline
    easing.bezierCurve: {
        const c = Appearance.anim.curves;

        switch (type) {
        case Anim.FastSpatial:
            return c.expressiveFastSpatial;
        case Anim.DefaultSpatial:
            return c.expressiveDefaultSpatial;
        case Anim.SlowSpatial:
            return c.expressiveSlowSpatial;
        case Anim.FastEffects:
            return c.expressiveFastEffects;
        case Anim.DefaultEffects:
            return c.expressiveDefaultEffects;
        case Anim.SlowEffects:
            return c.expressiveSlowEffects;
        }

        if (type >= Anim.EmphasizedSmall && type <= Anim.EmphasizedExtraLarge)
            return c.emphasized;
        return c.standard;
    }
}
