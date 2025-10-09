;;; tasker.el --- Tasker helps running project tasks -*- lexical-binding:t -*-
;;
;; Author: pablololo12
;; URL: https://github.com/Pablololo12/tasker.el
;; Version: 0.1
;; Keywords: frames convenience terminals
;; Package-Requires: ((emacs "25.1"))
;;
;;; License
;; This file is not part of GNU Emacs.
;;
;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.
;;
;;; Commentary:
;; Term-control allows to easily handle pop-up vterm windows in your emacs.
;;
;;; Code:

(require 'cl-lib)

;; Configs

(defgroup tasker nil
  "Runs project defined tasks"
  :prefix "tasker-"
  :group 'applications)

;; Helper Functions

(defun tasker-get-config-file ()
  "Gets the config file at the root of the project"
  (expand-file-name ".tasker.cfg" (projectile-project-root)))

(defun tasker-read-lines (filePath)
  "Return a list of lines of a file at filePath."
  (with-temp-buffer
    (insert-file-contents filePath)
    (split-string (buffer-string) "\n" t)))

(defun tasker-parse-line (line)
  "Parses a config line and returns a pair"
  (let* ((spl (split-string line ":" t))
         (one (car spl))
         (two (string-trim (car (cdr spl)))))
    (cons one two)))

(defun tasker-read-config ()
  "Reads config and returns a list of pairs"
  (let ((content (tasker-read-lines (tasker-get-config-file))))
    (mapcar #'tasker-parse-line content)))

(defun tasker-get-options (tasks)
  "Returns a list of options"
  (mapcar #'car tasks))

(defun tasker-get-command (tasks selection)
  "Search in the list for the selected task"
  (cdr (assoc selection tasks)))

(defun tasker-run-task-helper (command)
  "Run the command selected from the project root."
  (let ((default-directory (projectile-project-root)))
    (async-shell-command command)))

;; User Interface

(defun tasker-run-task ()
  "Asks to select a task from a list of defined tasks"
  (interactive)
  (let* ((tasks (tasker-read-config))
         (choices (tasker-get-options tasks))
         (selected (completing-read "Choose task: " choices nil nil)))
    (tasker-run-task-helper (tasker-get-command tasks selected))))

(provide 'tasker)
