;;;; weblocks-dataseq-records-count-panel.asd

(asdf:defsystem #:weblocks-dataseq-records-count-panel
  :serial t
  :description "Records count chooser for weblocks dataseq"
  :author "Olexiy Zamkoviy <olexiy.z@gmail.com>"
  :licence "LLGPL"
  :depends-on (:weblocks)
  :components ((:file "package")
               (:file "weblocks-dataseq-records-count-panel")))

