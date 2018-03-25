;;; flycheck-ruby-dockerized-rubocop.el --- Let rubocop work under docker container

;; Copyright (C) 2018 Alexey Ermolaev

;; Author: Alexey Ermolaev <afay.zangetsu@gmail.com>
;; Keywords: flycheck ruby rubocop docker
;; URL: https://github.com/AfsmNGhr/flycheck-ruby-dockerized-rubocop
;; Version: 0.0.1
;; Package-Requires: ((flycheck "31") (emacs "24"))

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This is extension for Flycheck.

;;; Setup

;; Install docker.

;; Install rubocop inside container.

;;; Code:

(require 'flycheck)

(flycheck-def-executable-var ruby-dockerized-rubocop "docker")

(flycheck-def-config-file-var dockerized-rubocoprc
    ruby-dockerized-rubocop
    ".rubocop.yml"
    :safe #'stringp
    :package-version '(flycheck . "31"))

(flycheck-def-option-var ruby-dockerized-rubocop-local-path
    "/mnt/workspace/Documents/Work/core.services/services/preset.service"
    ruby-dockerized-rubocop
  "Project VOLUME on host."
  :safe #'stringp
  :package-version '(flycheck . "31"))

(flycheck-def-option-var ruby-dockerized-rubocop-remote-path
    "/home/app"
    ruby-dockerized-rubocop
  "Project WORKDIR inside container."
  :safe #'stringp
  :package-version '(flycheck . "31"))

(flycheck-def-option-var ruby-dockerized-rubocop-command
    "rubocop"
    ruby-dockerized-rubocop
  "Rubocop command."
  :safe #'stringp
  :package-version '(flycheck . "31"))

(flycheck-def-option-var ruby-dockerized-rubocop-container-name
    "preset_preset_1"
    ruby-dockerized-rubocop
  "Container name where rubocop checker."
  :safe #'stringp
  :package-version '(flycheck . "31"))

(flycheck-def-args-var ruby-dockerized-rubocop-args
    ruby-dockerized-rubocop
  "Rubocop default ARGS."
  :initialize '("--display-cop-names"
                "--force-exclusion"
                "--format" "emacs"
                "--cache" "false")
  :safe #'stringp
  :type 'list
  :package-version '(flycheck . "31"))

;;;###autoload
(defun flycheck-verify-dockerized-rubocop (_checker)
  "Verify the dockerized rubocop syntax checker."
  (let ((command (executable-find (ruby-dockerized-rubocop-command))))
    (list (flycheck-verification-result-new
           :label "Dockerized rubocop command"
           :message (if command (format "Found at %s" command) "Not found")
           :face (if command 'success '(bold error))))))

(defun flycheck-parse-dockerized-rubocop (output checker buffer)
  (lambda (message)
    (message output)))

(flycheck-define-checker ruby-dockerized-rubocop
  "Ruby style guide checker using dockerized rubocop."
  :command ((option ruby-dockerized-rubocop) "exec" "-i"
            (option ruby-dockerized-rubocop-container-name)
            (eval ruby-dockerized-rubocop-command)
            (option ruby-dockerized-rubocop-args)
            "--config" (eval
                        (concat ruby-dockerized-rubocop-remote-path "/"
                                dockerized-rubocoprc))
            "app.rb")
  ;; :verify #'flycheck-verify-dockerized-rubocop
  ;; :error-filter (lambda (error) (message error))
  :error-parser #'flycheck-parse-dockerized-rubocop
  ;; :error-patterns
  ;; ((info line-start (file-name) ":" line ":" column ": C: "
         ;; (optional (id (one-or-more (not (any ":")))) ": ") (message) line-end)
   ;; (warning line-start (file-name) ":" line ":" column ": W: "
            ;; (optional (id (one-or-more (not (any ":")))) ": ") (message)
            ;; line-end)
   ;; (error line-start (file-name) ":" line ":" column ": " (or "E" "F") ": "
          ;; (optional (id (one-or-more (not (any ":")))) ": ") (message)
          ;; line-end))
  :modes (enh-ruby-mode ruby-mode)
  :next-checkers ((warning . ruby-rubocop)))

;;; flycheck-ruby-dockerized-rubocop.el ends here
