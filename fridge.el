;;; fridge --- fridge -*- lexical-binding: t; coding: utf-8; -*-

;;; Commentary:

;;; Code:


(cl-defun fridge:create (&optional file)
  (if file
      (glof:plist
       :type :file
       :file file)
    (glof:plist
     :type :memory
     :data nil)))

(cl-defun fridge:get (db &optinola key)
  (cl-labels ((get-data
                  (pcase (glof:get db :type)
                    (:file #'fridge:get-data-file)
                    (:memory #'fridge:get-data-file))))
    (if key
        (thread-first (get-data db)
          (glof:get key))
      (get-data db))))

(cl-defun fridge:get-data-file (db)
  (cl-letf ((file (glof:get db :file)))
    (with-temp-buffer (insert-file-contents file)
                      (read (current-buffer)))))

(cl-defun fridge::get-data-memory (db)
  (glof:get db :data))

(provide 'fridge)

;;; fridge.el ends here
