;;;; speak-bot.lisp

(in-package #:speak-bot)

(defun clean-output-folder ()
  (mapcar #'uiop:delete-file-if-exists (uiop:directory-files *output* "*.wav")))

(defun make-reply (notification)
  (when (mention-p notification)
    (let* ((status (tooter:status notification))
	   (media-file (speak-status (tooter:content status)
				     :pitch (+ 30 (random 40))
				     :amplitude (+ 70 (random 60)))))

      (when (log:info)
	(log:info "replying to" (tooter:id status)
		  "with" media-file))
      
      ;; may not need the space? idk can probably just nothing :shrug:
      (if media-file
	  (reply status " " :media media-file)
	  (reply status *error-message*)))))

(defun speak-status (text &key pitch amplitude)
  (let ((filename (merge-pathnames (concatenate 'string
						(string (gensym "AUDIO-")) ".wav")
				   *output*)))
    (multiple-value-bind (state code) (run "/usr/bin/env" (list #+bsd "espeak" #+linux "speak"
								(format nil "-w ~a" filename)
								(format nil "-p ~a" pitch)
								(format nil "-a ~a" amplitude)
								text))
      (if (and (eq state :exited)
	       (zerop code))
	  filename
	  (log:warn "speak program returned with error code" code)))))
								   

(defun main ()
  (log:config :warn)
  
  (multiple-value-bind (opts args) (get-opts)
    (when (or (getf opts :help)
	      (every #'null opts))
      (unix-opts:describe
       :usage-of "speak-bot")
      (uiop:quit 0))
    
    (when (getf opts :config)
      (setf *config-file* (getf opts :config)))

    (when (getf opts :log)
      (log:config :info))

    (when (getf opts :output)
      (setf *output* (getf opts :output))
      (ensure-directories-exist *output*)))

  (handler-case
      (with-user-abort
	(run-bot (make-instance 'mastodon-bot
				:config-file *config-file*
				:on-notification #'make-reply)
;	  (after-every (2 :days) (clean-output-folder))
	  ;; maybe read random statuses from federated timeline?
	  ;; :shrug:
	  ))
    (user-abort ()
      (when (log:info)
	(log:info "shutting down")))
    (error (e)
      (log:error "hit unrecoverable error" e))))
