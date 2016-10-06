include '../../types.pxi'
from cython.operator cimport dereference as deref
from libcpp.vector cimport vector

cimport _piecewise_yield_curve as _pyc

from quantlib.handle cimport shared_ptr

cimport _rate_helpers as _rh
cimport quantlib.termstructures._yield_term_structure as _yts


from rate_helpers cimport RateHelper
from quantlib.time.date cimport Date
from quantlib.time.daycounter cimport DayCounter
from quantlib.time.calendar cimport Calendar

from quantlib.termstructures.yields.yield_term_structure cimport YieldTermStructure


from enum import IntEnum

globals()["BootstrapTrait"] = IntEnum('BootstrapTrait',
        [('Discount', 0), ('ZeroYield', 1), ('ForwardRate', 2)])
globals()["Interpolator"] = IntEnum('Interpolator',
        [('Linear', 0), ('LogLinear', 1), ('BackwardFlat', 2)])


cdef class PiecewiseYieldCurve(YieldTermStructure):
    """A piecewise yield curve.

    Parameters
    ----------
    trait : str
        the kind of curve. Must be either 'discount', 'forward' or 'zero'
    interpolator : str
        the kind of interpolator. Must be either 'loglinear', 'linear' or
        'spline'
    settlement_date : quantlib.time.date.Date
        The settlement date
    helpers : list of quantlib.termstructures.rate_helpers.RateHelper
        a list of rate helpers used to create the curve
    day_counter : quantlib.time.day_counter.DayCounter
        the day counter used by this curve
    tolerance : double (default 1e-12)
        the tolerance

    """

    def __init__(self, BootstrapTrait trait, Interpolator interpolator,
                 Natural settlement_days, Calendar calendar not None,
                 list helpers, DayCounter daycounter not None,
                 Real accuracy = 1e-12):


        if len(helpers) == 0:
            raise ValueError('Cannot initialize curve with no helpers')

        self._trait = trait
        self._interpolator = interpolator

        # convert Python list to std::vector
        cdef vector[shared_ptr[_rh.RateHelper]] instruments

        for helper in helpers:
            instruments.push_back(
                deref((<RateHelper?> helper)._thisptr)
            )

        if trait == Discount:
            if interpolator == Linear:
                self._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.Discount,_pyc.Linear](
                        settlement_days, deref(calendar._thisptr), instruments,
                        deref(daycounter._thisptr), accuracy)))
            elif interpolator == LogLinear:
                self._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.Discount,_pyc.LogLinear](
                        settlement_days, deref(calendar._thisptr), instruments,
                        deref(daycounter._thisptr), accuracy)))
            else:
                self._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.Discount,_pyc.BackwardFlat](
                        settlement_days, deref(calendar._thisptr), instruments,
                        deref(daycounter._thisptr), accuracy)))
        elif trait == ZeroYield:
            if interpolator == Linear:
                self._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.ZeroYield,_pyc.Linear](
                        settlement_days, deref(calendar._thisptr), instruments,
                        deref(daycounter._thisptr), accuracy)))
            elif interpolator == LogLinear:
                self._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.ZeroYield,_pyc.LogLinear](
                        settlement_days, deref(calendar._thisptr), instruments,
                        deref(daycounter._thisptr), accuracy)))
            else:
                self._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.ZeroYield,_pyc.BackwardFlat](
                        settlement_days, deref(calendar._thisptr), instruments,
                        deref(daycounter._thisptr), accuracy)))
        else:
            if interpolator == Linear:
                self._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.ForwardRate,_pyc.Linear](
                        settlement_days, deref(calendar._thisptr), instruments,
                        deref(daycounter._thisptr), accuracy)))
            elif interpolator == LogLinear:
                self._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.ForwardRate,_pyc.LogLinear](
                        settlement_days, deref(calendar._thisptr), instruments,
                        deref(daycounter._thisptr), accuracy)))
            else:
                self._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.ForwardRate,_pyc.BackwardFlat](
                        settlement_days, deref(calendar._thisptr), instruments,
                        deref(daycounter._thisptr), accuracy)))

    @classmethod
    def from_reference_date(cls, BootstrapTrait trait, Interpolator interpolator,
                            Date reference_date, list helpers,
                            DayCounter daycounter not None, Real accuracy=1e-12):

        if len(helpers) == 0:
            raise ValueError('Cannot initialize curve with no helpers')

        # convert Python list to std::vector
        cdef vector[shared_ptr[_rh.RateHelper]] instruments

        cdef PiecewiseYieldCurve instance = cls.__new__(cls)
        for helper in helpers:
            instruments.push_back(
                deref((<RateHelper?> helper)._thisptr)
            )

        instance._trait = trait
        instance._interpolator = interpolator
        if trait == Discount:
            if interpolator == Linear:
                instance._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.Discount,_pyc.Linear](
                        deref(reference_date._thisptr.get()), instruments,
                        deref(daycounter._thisptr), accuracy)))
            elif interpolator == LogLinear:
                instance._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.Discount,_pyc.LogLinear](
                        deref(reference_date._thisptr.get()), instruments,
                        deref(daycounter._thisptr), accuracy)))
            else:
                instance._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.Discount,_pyc.BackwardFlat](
                        deref(reference_date._thisptr.get()), instruments,
                        deref(daycounter._thisptr), accuracy)))
        elif trait == ZeroYield:
            if interpolator == Linear:
                instance._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.ZeroYield,_pyc.Linear](
                        deref(reference_date._thisptr.get()), instruments,
                        deref(daycounter._thisptr), accuracy)))
            elif interpolator == LogLinear:
                instance._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.ZeroYield,_pyc.LogLinear](
                        deref(reference_date._thisptr.get()), instruments,
                        deref(daycounter._thisptr), accuracy)))
            else:
                instance._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.ZeroYield,_pyc.BackwardFlat](
                        deref(reference_date._thisptr.get()), instruments,
                        deref(daycounter._thisptr), accuracy)))
        else:
            if interpolator == Linear:
                instance._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.ForwardRate,_pyc.Linear](
                        deref(reference_date._thisptr.get()), instruments,
                        deref(daycounter._thisptr), accuracy)))
            elif interpolator == LogLinear:
                instance._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.ForwardRate,_pyc.LogLinear](
                        deref(reference_date._thisptr.get()), instruments,
                        deref(daycounter._thisptr), accuracy)))
            else:
                instance._thisptr.linkTo(shared_ptr[_yts.YieldTermStructure](
                    new _pyc.PiecewiseYieldCurve[_pyc.ForwardRate,_pyc.BackwardFlat](
                        deref(reference_date._thisptr.get()), instruments,
                        deref(daycounter._thisptr), accuracy)))
        return instance
