;;;; speak-bot.asd

(asdf:defsystem #:speak-bot
  :description "mastodon bot that speaks"
  :author "ava fox"
  :license  "NPLv1+"
  :version "0.0.1"
  :serial t
  :depends-on (#:glacier #:external-program
	       #:with-user-abort #:unix-opts
	       #:log4cl)
  :components ((:file "package")
               (:file "speak-bot"))
  :build-operation "program-op"
  :build-pathname "bin/speak-bot"
  :entry-point "speak-bot::main")

#+sb-core-compression
(defmethod asdf:perform ((o asdf:image-op) (c asdf:system))
  (uiop:dump-image (asdf:output-file o c) :executable t :compression t))

