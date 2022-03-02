# dcmodifydb 0.3.0

* Improved messages for non-working rules (#1) Thanks to Marlou van de Sande

* Fix for statements using %in% (bug #2), this was due to validate which replaced it with %vin%. Thanks to Marlou van de Sande for reporting.

* Tables in a schema were not working (bug issue #3), is now fixed.

* Added restriction R >= 4.0. Thanks to @Wytzepakito, #6
