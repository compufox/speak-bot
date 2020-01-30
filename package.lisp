;;;; package.lisp

(defpackage #:speak-bot
  (:use #:cl #:glacier #:with-user-abort)
  (:import-from :unix-opts
                :get-opts
		:define-opts)
  (:import-from :external-program
		:run))
(in-package #:speak-bot)

(defvar *config-file* nil)
(defvar *output* (uiop:temporary-directory))
(defvar *error-message* "oops something went wrong! :/")

(define-opts
  (:name :help
   :description "prints this help text"
   :short #\h
   :long "help")
  (:name :output
   :description "folder to output audio clips (DEFAULTS TO /tmp)"
   :short #\o
   :long "output"
   :meta-var "DIRECTORY"
   :arg-parser #'identity)
  (:name :config
   :description "config file to use"
   :short #\c
   :long "config"
   :meta-var "CONFIG"
   :arg-parser #'identity)
  (:name :log
   :description "enable logging"
   :short #\l
   :long "log"))
   
