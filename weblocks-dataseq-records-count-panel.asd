;;;; weblocks-dataseq-records-count-panel.asd

(asdf:defsystem #:weblocks-dataseq-records-count-panel
  :serial t
  :description "Records count chooser for weblocks dataseq"
  :author "Olexiy Zamkoviy <olexiy.z@gmail.com>"
  :version "0.0.1"
  :licence "LLGPL"
  :depends-on (:weblocks :yaclml)
  :components ((:file "package")
               (:file "weblocks-dataseq-records-count-panel")))

