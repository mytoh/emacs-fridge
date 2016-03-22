;;; fridge --- fridge -*- lexical-binding: t; coding: utf-8; -*-

;;; Commentary:

;;; Code:

(require 'cl-lib)
(require 'subr-x)

(require 'glof)

(cl-defun fridge:create (&optional file)
  (if file
      (glof:plist
       :fridge/type :file
       :fridge/file file
       :fridge/read #'fridge::read-file
       :fridge/write #'fridge::write-file)
    (glof:plist
     :fridge/type :memory
     :fridge/data nil
     :fridge/read #'fridge::read-memory
     :fridge/write #'fridge::write-memory)))

(cl-defun fridge:write (db data)
  (glof:call db :fridge/write
             db data))

(cl-defun fridge::write-file (db data)
  (with-temp-file (glof:get db :fridge/file)
    (cl-letf ((standard-output (current-buffer)))
      (prin1 data)))
  db)

(cl-defun fridge::write-memory (db data)
  (glof:assoc db
              :fridge/data data))

(cl-defun fridge:read (db)
  (glof:call db :fridge/read
             db))

(cl-defun fridge::read-file (db)
  (cl-letf ((file (glof:get db :fridge/file)))
    (with-temp-buffer (insert-file-contents file)
                      (read (current-buffer)))))

(cl-defun fridge::read-memory (db)
  (glof:get db :fridge/data))


(cl-letf ((db (fridge:create)))
  (cl-equalp
   "test"
   (thread-first db
     (fridge:write  "test")
     fridge:read)))


(cl-letf ((db (fridge:create "test-db.el")))
  (cl-equalp
   "test"
   (thread-first db
     (fridge:write  "test")
     fridge:read)))

(provide 'fridge)

;;; fridge.el ends here
