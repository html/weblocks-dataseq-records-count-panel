;;;; weblocks-dataseq-records-count-panel.lisp

(in-package #:weblocks-dataseq-records-count-panel)

(defmacro with-yaclml (&body body)
  "A wrapper around cl-yaclml with-yaclml-stream macro."
  `(yaclml:with-yaclml-stream *weblocks-output-stream*
     ,@body))

(defwidget dataseq-records-count-panel (widget)
  ((choose-variants 
     :initargs :variants 
     :initform '((10 . "10")
                 (20 . "20")
                 (50 . "50")
                 (100 . "100")
                 (:all . "All")))
   (choosen-variant :initform 10)
   (dataseq-instance :initarg :dataseq-instance 
                     :initform (error ":dataseq-instance is required for dataseq-records-count-panel"))
   (initial-count :initarg :initial-count :initform 10)
   (change-items-per-page-action :initform  "change-items-per-page")))

(defmethod set-items-per-page-count ((widget dataseq-records-count-panel) count)
  (with-slots (dataseq-instance choosen-variant) widget
    (let ((final-count 
            (cond 
              ((integerp count) count) 
              ((equal count :all)
               (if (zerop (dataseq-data-count (slot-value widget 'dataseq-instance)))
                 1000000
                 (* 2 (dataseq-data-count (slot-value widget 'dataseq-instance))))) 
              (t (error "Don't know what to do with count ~A" count))))) 
      (setf (pagination-items-per-page (dataseq-pagination-widget dataseq-instance)) final-count) 
      (setf (pagination-current-page (dataseq-pagination-widget dataseq-instance)) 1)) 
    (setf choosen-variant count)
    (mark-dirty widget) 
    (mark-dirty dataseq-instance)))

(defmethod set-default-items-count ((widget dataseq-records-count-panel))
  (with-slots (initial-count) widget 
    (set-items-per-page-count widget initial-count)))

(defmethod set-change-items-per-page-action ((widget dataseq-records-count-panel))
  (with-slots (change-items-per-page-action) widget
    (make-action 
      (lambda (&rest args)
        (let ((per-page 
                (if (string= (getf args :per_page) ":ALL")
                  :all
                  (parse-integer (getf args :per_page)))))
          (when per-page 
            (set-items-per-page-count widget per-page))))
      change-items-per-page-action)))

(defmethod initialize-instance :after ((widget dataseq-records-count-panel) &rest args)
  (set-default-items-count widget)
  (set-change-items-per-page-action widget))

(defmethod current-dataseq-instance-items-per-page ((widget dataseq-records-count-panel))
  (with-slots (dataseq-instance) widget 
    (pagination-items-per-page (dataseq-pagination-widget dataseq-instance))))

(defmethod max-items-per-page-count ((widget dataseq-records-count-panel))
  (with-slots (choose-variants) widget 
    (apply #'max (remove-if-not #'integerp (mapcar #'car choose-variants)))))

(defmethod items-per-page-equal-to-p ((widget dataseq-records-count-panel) count)
  (let ((items-per-page (current-dataseq-instance-items-per-page widget)))
    (cond 
      ((integerp count)
       (= count items-per-page))
      ((equal count :all) 
       (equal count (slot-value widget 'choosen-variant)))
      (t (error (format nil "Don't know what to do with count ~A" count))))))

(defmethod render-widget-body ((widget dataseq-records-count-panel) &rest args)
  (with-slots (choose-variants change-items-per-page-action) widget
    (with-yaclml 
      (<:as-is "Display ")
      (<:div :class "btn-group"
             (loop for (value . title) in choose-variants do
                   (<:button 
                     :onclick (format 
                                nil "initiateActionWithArgs(\"~A\", \"~A\", {per_page: \"~A\"})"
                                change-items-per-page-action 
                                (session-name-string-pair)
                                (write-to-string value))
                     :class (concatenate 'string 
                                                 "btn"
                                                 (when (items-per-page-equal-to-p widget value)
                                                   " active"))
                             (<:as-is title))))
      (<:as-is " records per page"))))
