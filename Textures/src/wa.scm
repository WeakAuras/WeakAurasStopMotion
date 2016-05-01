(define (postproces-layer layer i x y name)
  (gimp-drawable-set-visible layer 1)
  (gimp-layer-set-offsets layer x y)
  (gimp-layer-set-name layer (string-append name " " (number->string i)))
  )

(define (postproces-layers layer i x y name)
  (if (list? layer)
    (map (lambda (l) (postproces-layer l i x y name)) layer)
    (postproces-layer layer i x y name)))

(define (ease-linear p)
        p)

(define (ease-quadratic p)
        (* p p))

(define (ease-cubic p)
        (* p p p))

(define (ease-out func)
        (lambda (p) (- 1 (func (- 1 p)))))

(define (ease-in-out func)
        (lambda (p)
           (if (< p 0.5) (/ (func (* 2 p)) 2)
                         (- 1 (/ (func (* (- 1 p) 2)) 2)))))

(define wa-easing-functions
  (list ease-linear
  ease-quadratic
  (ease-out ease-quadratic)
  (ease-in-out ease-quadratic)
  ease-cubic
  (ease-out ease-cubic)
  (ease-in-out ease-cubic))
)

(define wa-easing-functions-desc
  (list "Linear"
        "Quadratic Ease In" "Quadratic Ease Out" "Quadratic Ease In/Out"
        "Cubic Ease In" "Cubic Ease Out" "Cubic Ease In/Out")
)

(define (script-fu-wa img layer rows columns function args)
    (define (create-layers i rows columns width height img layer function args)
       (let* ((newlayer (car (gimp-layer-new-from-drawable layer img)))
              (total (- (* rows columns) 1))
              (row (floor (/ i columns)))
              (col (remainder i columns)))
             (gimp-image-insert-layer img newlayer (car (gimp-item-get-parent layer)) -10)
             (let* ((modifiedlayer (function img newlayer i total args)))
               (postproces-layers modifiedlayer i (* col width) (* row height) (car (gimp-layer-get-name layer))))
             (if (< i total)
               (create-layers (+ i 1) rows columns width height img layer function args))
             ))
    ; Start gimp2 with --console-messages
    ; (gimp-message-set-handler CONSOLE)
    ; (gimp-message "foobar")
    (let* ((width (car (gimp-drawable-width layer)))
           (height (car (gimp-drawable-height layer)))
           (imgwidth (car (gimp-image-width img)))
           (imgheight (car (gimp-image-height img)))
           )
        (gimp-undo-push-group-start img)
        (if (or (not (= imgwidth (* width columns))) (not (= imgheight (* height rows))))
          (gimp-image-resize img (* width columns)
                                 (* height rows)
                                 0 0))
        (gimp-item-set-linked layer 0)
        (create-layers 0 rows columns width height img layer function args)
        (gimp-layer-set-visible layer 0)
        (gimp-undo-push-group-end img)
        (gimp-displays-flush)
    )
)

(define (wa-blur-horizontal img newlayer i total args)
  (let* ((blur-length (car args))
         (fade-in (cadr args))
         (easing (caddr args))
         (percent (/ i total))
         (len (* (- 1 (easing percent)) blur-length))
         (opacity-until (or (and (= fade-in 1) (/ total 3)) -1))
         (opacity (or (and (< i opacity-until) (* (/ i opacity-until) 100)) 100))
         (width (car (gimp-drawable-width newlayer)))
         (height (car (gimp-drawable-height newlayer)))
         )
        (plug-in-mblur 1 img newlayer 0 len 0 (/ width 2) (/ height 2))
        (gimp-layer-set-opacity newlayer opacity))
        newlayer)

(define (wa-blur-radial img newlayer i total args)
  (let* ((max-blur (nth 0 args))
         (maxrotate (* (/ (nth 1 args) 180) (* 4 (atan 1.0))))
         (blureasing (nth 2 args))
         (rotateeasing (nth 3 args))
         (fade-in (nth 4 args))
         (percent (/ i total))
         (a (* (- (blureasing percent) 1) max-blur))
         (opacity-until (or (and (= fade-in 1) (/ total 3)) -1))
         (opacity (or (and (< i opacity-until) (* (/ i opacity-until) 100)) 100))
         (width (car (gimp-drawable-width newlayer)))
         (height (car (gimp-drawable-height newlayer)))
         )
        (plug-in-mblur 1 img newlayer 1 0 a (/ width 2) (/ height 2))
        (gimp-item-transform-rotate newlayer (* (- 1 (rotateeasing percent)) maxrotate) TRUE 0 0)
        (let* ((nwidth (car (gimp-drawable-width newlayer)))
               (nheight (car (gimp-drawable-height newlayer))))
          (gimp-layer-resize newlayer width height (/ (- width nwidth) 2) (/ (- height nheight) 2))
        )
        (gimp-layer-set-opacity newlayer opacity)
        )
        newlayer)

(define (wa-spotlight-horizontal-word img newlayer i total args)
  (let* ((newlayer2 (car (gimp-layer-new-from-drawable newlayer img)))
         (newlayer3 (car (gimp-layer-new-from-drawable newlayer img)))
         (width (car (gimp-drawable-width newlayer)))
         (height (car (gimp-drawable-height newlayer)))
         (percent (/ i total))
         (gradientwidth (car args))
         (gradientwidth2 (cadr args))
         (offset (caddr args))
         (coveredwidth (- width (* 2 offset)))
         (x1 (+ offset (* percent coveredwidth)))
         (x2 (+ offset gradientwidth (* percent coveredwidth)))
         (x3 (+ offset gradientwidth2 (* percent coveredwidth)))
         (oldforeground (car (gimp-context-get-foreground)))
         (oldbackground (car (gimp-context-get-background)))
         )
        (gimp-context-set-background '(0 0 0) )
        (gimp-context-set-foreground '(255 255 255) )
        (gimp-image-insert-layer img newlayer2 (car (gimp-item-get-parent newlayer)) -10)
        (gimp-image-insert-layer img newlayer3 (car (gimp-item-get-parent newlayer)) -10)
        (gimp-layer-set-mode newlayer3 16)
        (let* ((mask (car (gimp-layer-create-mask newlayer3 0))))
          (gimp-layer-add-mask newlayer3 mask)
          (gimp-edit-blend newlayer3 0 0 1 100 0 0 0 1 5 4 1 x1 0 x2 0))
        (let* ((mask (car (gimp-layer-create-mask newlayer2 0))))
          (gimp-layer-add-mask newlayer2 mask)
          (gimp-edit-blend mask 0 0 1 100 0 0 0 1 5 4 1 x1 0 x3 0))
        (gimp-desaturate newlayer)
        (gimp-layer-set-opacity newlayer 80)
        (gimp-context-set-background oldbackground)
        (gimp-context-set-foreground oldforeground)
        (list newlayer newlayer2 newlayer3)))
        
(define (wa-spotlight-vertical-word img newlayer i total args)
  (let* ((newlayer2 (car (gimp-layer-new-from-drawable newlayer img)))
         (newlayer3 (car (gimp-layer-new-from-drawable newlayer img)))
         (width (car (gimp-drawable-width newlayer)))
         (height (car (gimp-drawable-height newlayer)))
         (percent (/ i total))
         (gradientheight (car args))
         (gradientheight2 (cadr args))
         (offset (caddr args))
         (coveredheight (- height (* 2 offset)))
         (y1 (+ offset (* percent coveredheight)))
         (y2 (+ offset gradientheight (* percent coveredheight)))
         (y3 (+ offset gradientheight2 (* percent coveredheight)))
         (oldforeground (car (gimp-context-get-foreground)))
         (oldbackground (car (gimp-context-get-background)))
         )
        (gimp-context-set-background '(0 0 0) )
        (gimp-context-set-foreground '(255 255 255) )
        (gimp-image-insert-layer img newlayer2 (car (gimp-item-get-parent newlayer)) -10)
        (gimp-image-insert-layer img newlayer3 (car (gimp-item-get-parent newlayer)) -10)
        (gimp-layer-set-mode newlayer3 16)
        (let* ((mask (car (gimp-layer-create-mask newlayer3 0))))
          (gimp-layer-add-mask newlayer3 mask)
          (gimp-edit-blend newlayer3 0 0 1 100 0 0 0 1 5 4 1 0 y1 0 y2))
        (let* ((mask (car (gimp-layer-create-mask newlayer2 0))))
          (gimp-layer-add-mask newlayer2 mask)
          (gimp-edit-blend mask 0 0 1 100 0 0 0 1 5 4 1 0 y1 0 y3))
        (gimp-desaturate newlayer)
        (gimp-layer-set-opacity newlayer 80)
        (gimp-context-set-background oldbackground)
        (gimp-context-set-foreground oldforeground)
        (list newlayer newlayer2 newlayer3)))

(define (wa-spotlight-horizontal img newlayer i total args)
  (let* ((newlayer2 (car (gimp-layer-new-from-drawable newlayer img)))
         (width (car (gimp-drawable-width newlayer)))
         (height (car (gimp-drawable-height newlayer)))
         (percent (/ i total))
         (gradientwidth (car args))
         (offset (cadr args))
         (coveredwidth (- width (* 2 offset)))
         (x1 (+ offset (* percent coveredwidth)))
         (x2 (+ offset gradientwidth (* percent coveredwidth)))
         (oldforeground (car (gimp-context-get-foreground)))
         (oldbackground (car (gimp-context-get-background)))
         )
        (gimp-context-set-background '(0 0 0) )
        (gimp-context-set-foreground '(255 255 255) )
        (gimp-image-insert-layer img newlayer2 (car (gimp-item-get-parent newlayer)) -10)
        (gimp-layer-set-mode newlayer2 16)
        (let* ((mask (car (gimp-layer-create-mask newlayer2 0))))
          (gimp-layer-add-mask newlayer2 mask)
          (gimp-edit-blend newlayer2 0 0 1 100 0 0 0 1 5 4 1 x1 0 x2 0))
        (gimp-context-set-background oldbackground)
        (gimp-context-set-foreground oldforeground)
        (car (gimp-image-merge-down img newlayer2 0))))
        
(define (wa-spotlight-vertical img newlayer i total args)
  (let* ((newlayer2 (car (gimp-layer-new-from-drawable newlayer img)))
         (width (car (gimp-drawable-width newlayer)))
         (height (car (gimp-drawable-height newlayer)))
         (percent (/ i total))
         (gradientheight (car args))
         (offset (cadr args))
         (coveredheight (- width (* 2 offset)))
         (y1 (+ offset (* percent coveredheight)))
         (y2 (+ offset gradientheight (* percent coveredheight)))
         (oldforeground (car (gimp-context-get-foreground)))
         (oldbackground (car (gimp-context-get-background)))
         )
        (gimp-context-set-background '(0 0 0) )
        (gimp-context-set-foreground '(255 255 255) )
        (gimp-image-insert-layer img newlayer2 (car (gimp-item-get-parent newlayer)) -10)
        (gimp-layer-set-mode newlayer2 16)
        (let* ((mask (car (gimp-layer-create-mask newlayer2 0))))
          (gimp-layer-add-mask newlayer2 mask)
          (gimp-edit-blend newlayer2 0 0 1 100 0 0 0 1 5 4 1 0 y1 0 y2))
        (gimp-context-set-background oldbackground)
        (gimp-context-set-foreground oldforeground)
        (car (gimp-image-merge-down img newlayer2 0))))

(define (wa-circle-mask img newlayer i total args)
  (define (wa-add-stroke path stroke cx cy radians width height)
    (let* ((s (* (sin radians) width 3))
           (c (* (cos radians) height 3)))
    (gimp-vectors-bezier-stroke-lineto path stroke (+ cx s) (- cy c))))

  (define (interpolate start end percent)
    (+ start (* percent (- end start))))

  (let* ((width (car (gimp-drawable-width newlayer)))
         (height (car (gimp-drawable-height newlayer)))
         (rotate-center (cadddr args))
         (mx (if (= rotate-center TRUE) (/ width 2) (cadr (cdddr args))))
         (my (if (= rotate-center TRUE) (/ height 2) (caddr (cdddr args))))
         (percent (/ i total))
         (pi (* 4 (atan 1.0)))
         (startradians (/ (* (car args) pi) 180))
         (endradians (/ (* (cadr args) pi) 180))
         (radians (interpolate startradians endradians percent))
         (path (car (gimp-vectors-new img "path")))
         (inverse (caddr args)))
        (gimp-image-insert-vectors img path 0 -1)
            (let* ((stroke (car (gimp-vectors-bezier-stroke-new-moveto path mx my))))
               (wa-add-stroke path stroke mx my startradians width height)
               (if (>= percent 0.25)
                 (wa-add-stroke path stroke mx my (interpolate startradians endradians 0.25) width height))
               (if (>= percent 0.50)
                 (wa-add-stroke path stroke mx my (interpolate startradians endradians 0.5) width height))
               (if (>= percent 0.75)
                 (wa-add-stroke path stroke mx my (interpolate startradians endradians 0.75) width height))
               (wa-add-stroke path stroke mx my radians width height)
               (gimp-vectors-bezier-stroke-lineto path stroke mx my)
               (gimp-image-select-item img 2 path)
               (if (= inverse TRUE) (gimp-selection-invert img))
               (let* ((mask (car (gimp-layer-create-mask newlayer 4))))
                   (gimp-layer-add-mask newlayer mask))
               (gimp-selection-none img)
               (gimp-image-remove-vectors img path))
            )
    newlayer)


(define (wa-spinning-orb img newlayer i total args)
  (let*
    ((percent (/ i total))
     (a (* percent 360)))

    (plug-in-map-object 1 img newlayer
                        1                ; mapping type
                        0.5 0.5 2        ; viewport
                        0.5 0.5 0.0      ; object position
                        1.0 0 0          ; first axis
                        0.0 1.0 0.0      ; second axis
                        0 a 0.0          ; axis rotation
                        1 '(255 255 255) ; light source
                        -0.5 -0.5 2      ; light position
                        -1.0 -1.0 1.0    ; light direction
                        0.3 1.2 0.7 0.0 27 ; material (amb, diff, refl, spec, high)
                        TRUE             ; antialias
                        TRUE            ; tile
                        FALSE            ; newimage
                        TRUE             ; transparency
                        .3               ; radius
                        0.5 0.5 0.5      ; scale
                        1                ; Cylinder length
                        -1 -1 -1 -1 -1 -1; Box drawables
                        -1 -1            ; Cylinder drawables
                        ))
  newlayer)

(define (wa-stroke-path img layer i total args)
  (define (draw-point layer position path-length path stroke brush spacing)
     (let* ((pos (gimp-vectors-stroke-get-point-at-dist path stroke position 1))
             (point (cons-array 2 'double)))
             (aset point 0 (car pos))
             (aset point 1 (cadr pos))
             (if (cadddr pos)
               (gimp-paintbrush-default layer 2 point)))
     (if (< (+ position spacing) path-length)
         (draw-point layer (+ position spacing) path-length path stroke brush spacing)))

  (gimp-context-push)
  (gimp-image-undo-group-start img)
  (let* ((path (car args))
         (stroke-width (cadr args))
         (spacing (caddr args))
         (startFrame (cadddr args))
         (endFrame (cadddr (cdr args)))
         (easing-function (cadddr (cddr args)))
         (brush (car (gimp-brush-new "WA-TMP-STROKE-BRUSH")))
         (first-stroke (aref (cadr (gimp-vectors-get-strokes path)) 0))
         (percent (easing-function (min (/ (- i startFrame) (+ (- endFrame startFrame) 1)) 1)))
         (path-length (* percent (car (gimp-vectors-stroke-get-length path first-stroke 1)))))

        (gimp-message (string-append (number->string i) " : " (number->string percent)))
        (gimp-brush-set-shape brush BRUSH-GENERATED-CIRCLE)
        (gimp-brush-set-radius brush stroke-width)
        (gimp-context-set-brush brush)

        (if (>= i startFrame)
          (draw-point layer 0 path-length path first-stroke brush spacing))
        (gimp-brush-delete brush)
  )
  (gimp-image-undo-group-end img)
  (gimp-context-pop)
  (gimp-displays-flush)
  layer
)


(define (wa-noop img newlayer i total args)
  newlayer)

(define (script-fu-wa-blur-horizontal img layer rows columns blur-length fade-in easing)
   (script-fu-wa img layer rows columns wa-blur-horizontal (list blur-length fade-in (nth easing wa-easing-functions))))

(define (script-fu-wa-blur-radial img layer rows columns max-blur maxrotate blureasing rotateeasing fade-in)
   (script-fu-wa img layer rows columns wa-blur-radial
     (list max-blur maxrotate (nth blureasing wa-easing-functions) (nth rotateeasing wa-easing-functions) fade-in)))

(define (script-fu-wa-spotlight-horizontal img layer rows columns highlight-width offset)
   (script-fu-wa img layer rows columns wa-spotlight-horizontal (list highlight-width offset)))
   
(define (script-fu-wa-spotlight-vertical img layer rows columns highlight-width offset)
   (script-fu-wa img layer rows columns wa-spotlight-vertical (list highlight-width offset)))

(define (script-fu-wa-spotlight-horizontal-word img layer rows columns highlight-width colored-width offset)
   (script-fu-wa img layer rows columns wa-spotlight-horizontal-word (list highlight-width colored-width offset)))
   
(define (script-fu-wa-spotlight-vertical-word img layer rows columns highlight-width colored-width offset)
   (script-fu-wa img layer rows columns wa-spotlight-vertical-word (list highlight-width colored-width offset)))

(define (script-fu-wa-circle-mask img layer rows columns sangle eangle inverse rotate-center mx my)
   (script-fu-wa img layer rows columns wa-circle-mask (list sangle eangle inverse rotate-center mx my)))

(define (script-fu-wa-spinning-orb img layer rows columns)
   (script-fu-wa img layer rows columns wa-spinning-orb '()))

(define (script-fu-wa-noop img layer rows columns)
   (script-fu-wa img layer rows columns wa-noop '()))

(define (script-fu-wa-duplicate-layer-once img layer rows columns)
  (let* ((iwidth (car (gimp-image-width img)))
         (iheight (car (gimp-image-height img)))
         (lwidth (/ iwidth columns))
         (lheight (/ iheight rows))
         (offsets (gimp-drawable-offsets layer))
         (posx (car offsets))
         (posy (cadr offsets))
         (newlayer (car (gimp-layer-new-from-drawable layer img))))
        (gimp-undo-push-group-start img)
        (gimp-image-insert-layer img newlayer (car (gimp-item-get-parent layer)) -10)
        (if (< (+ posx lwidth (/ lwidth 2)) iwidth)
          (gimp-layer-set-offsets newlayer (+ posx lwidth) posy)
          (gimp-layer-set-offsets newlayer 0 (+ posy lheight)))
        (gimp-displays-flush)
        (gimp-undo-push-group-end img)
        ))

(define (script-fu-wa-stroke-path img layer rows columns startFrame endFrame path stroke-width spacing easing)
   (script-fu-wa img layer rows columns wa-stroke-path
            (list path stroke-width spacing startFrame endFrame (nth easing wa-easing-functions))))


(script-fu-register "script-fu-wa-blur-horizontal"
                    "Linear Movement Blur"
                    "Movement Blur + Grid"
                    "Infus <infus@squorn.de>"
                    "Infus"
                    "8.3.2016"
                    ""
                    SF-IMAGE "Image" 0
                    SF-DRAWABLE "Drawable" 0
                    SF-ADJUSTMENT "Rows" (list 16 1 128 1 10 0 SF-SPINNER)
                    SF-ADJUSTMENT "Columns" (list 16 1 128 1 10 0 SF-SPINNER)
                    SF-ADJUSTMENT "Blur Length" (list 45 -100 100 1 10 0 SF-SPINNER)
                    SF-TOGGLE "Fade In" TRUE
                    SF-OPTION "Easing" wa-easing-functions-desc)

(script-fu-register "script-fu-wa-blur-radial"
                    "Radial Movement Blur"
                    "Movement Blur + Grid"
                    "Infus <infus@squorn.de>"
                    "Infus"
                    "8.3.2016"
                    ""
                    SF-IMAGE "Image" 0
                    SF-DRAWABLE "Drawable" 0
                    SF-ADJUSTMENT "Rows" (list 16 1 128 1 10 0 SF-SPINNER)
                    SF-ADJUSTMENT "Columns" (list 16 1 128 1 10 0 SF-SPINNER)
                    SF-ADJUSTMENT "Max Blur" (list -180 -360 360 1 10 0 SF-SPINNER)
                    SF-ADJUSTMENT "Max Rotate" (list -180 -720 720 1 10 0 SF-SPINNER)
                    SF-OPTION     "Blur Easing" wa-easing-functions-desc
                    SF-OPTION     "Rotate Easing" wa-easing-functions-desc
                    SF-TOGGLE "Fade In" TRUE
                    )

(script-fu-register "script-fu-wa-spotlight-horizontal"
                    "Horizontal Spotlight"
                    ""
                    "Infus <infus@squorn.de>"
                    "Infus"
                    "8.3.2016"
                    ""
                    SF-IMAGE "Image" 0
                    SF-DRAWABLE "Drawable" 0
                    SF-ADJUSTMENT "Rows" (list 16 1 128 1 10 0 SF-SPINNER)
                    SF-ADJUSTMENT "Columns" (list 16 1 128 1 10 0 SF-SPINNER)
                    SF-ADJUSTMENT "Highlight Width" (list 8 1 128 1 10 0 SF-SPINNER)
                    SF-ADJUSTMENT "Offset" (list 16 1 128 1 10 0 SF-SPINNER)
                    )
                    
(script-fu-register "script-fu-wa-spotlight-vertical"
                    "Vertical Spotlight"
                    ""
                    "Infus <infus@squorn.de>"
                    "Infus"
                    "8.3.2016"
                    ""
                    SF-IMAGE "Image" 0
                    SF-DRAWABLE "Drawable" 0
                    SF-ADJUSTMENT "Rows" (list 16 1 128 1 10 0 SF-SPINNER)
                    SF-ADJUSTMENT "Columns" (list 16 1 128 1 10 0 SF-SPINNER)
                    SF-ADJUSTMENT "Highlight Width" (list 8 1 128 1 10 0 SF-SPINNER)
                    SF-ADJUSTMENT "Offset" (list 16 1 128 1 10 0 SF-SPINNER)
                    )

(script-fu-register "script-fu-wa-spotlight-horizontal-word"
                    "Horizontal Spotlight Word"
                    ""
                    "Infus <infus@squorn.de>"
                    "Infus"
                    "8.3.2016"
                    ""
                    SF-IMAGE "Image" 0
                    SF-DRAWABLE "Drawable" 0
                    SF-ADJUSTMENT "Rows" (list 16 1 128 1 10 0 SF-SPINNER)
                    SF-ADJUSTMENT "Columns" (list 16 1 128 1 10 0 SF-SPINNER)
                    SF-ADJUSTMENT "Highlight Width" (list 32 1 128 1 10 0 SF-SPINNER)
                    SF-ADJUSTMENT "Colored Width" (list 32 1 128 1 10 0 SF-SPINNER)
                    SF-ADJUSTMENT "Offset" (list 4 1 128 1 10 0 SF-SPINNER)
                    )
                    
(script-fu-register "script-fu-wa-spotlight-vertical-word"
                    "Vertical Spotlight Word"
                    ""
                    "Infus <infus@squorn.de>"
                    "Infus"
                    "8.3.2016"
                    ""
                    SF-IMAGE "Image" 0
                    SF-DRAWABLE "Drawable" 0
                    SF-ADJUSTMENT "Rows" (list 16 1 128 1 10 0 SF-SPINNER)
                    SF-ADJUSTMENT "Columns" (list 16 1 128 1 10 0 SF-SPINNER)
                    SF-ADJUSTMENT "Highlight Width" (list 32 0 128 1 10 0 SF-SPINNER)
                    SF-ADJUSTMENT "Colored Width" (list 32 0 128 1 10 0 SF-SPINNER)
                    SF-ADJUSTMENT "Offset" (list 4 -5 128 1 10 0 SF-SPINNER)
                    )

(script-fu-register "script-fu-wa-circle-mask"
                    "Circle Mask"
                    ""
                    "Infus <infus@squorn.de>"
                    "Infus"
                    "8.3.2016"
                    ""
                    SF-IMAGE "Image" 0
                    SF-DRAWABLE "Drawable" 0
                    SF-ADJUSTMENT "Rows" (list 16 1 128 1 10 0 SF-SPINNER)
                    SF-ADJUSTMENT "Columns" (list 16 1 128 1 10 0 SF-SPINNER)
                    SF-ADJUSTMENT "Start Angle" (list 0 -360 720 1 15 1 SF-SPINNER)
                    SF-ADJUSTMENT "End Angle" (list 360 -360 720 1 15 1 SF-SPINNER)
                    SF-TOGGLE "Inverse" FALSE
                    SF-TOGGLE "Rotate around Center" TRUE
                    SF-ADJUSTMENT "Rotation Center X" (list 64 -1024 1024 1 10 0 SF-SPINNER)
                    SF-ADJUSTMENT "Rotation Center Y" (list 64 -1024 1024 1 10 0 SF-SPINNER)
                    )

(script-fu-register "script-fu-wa-spinning-orb"
                    "Orb spinning"
                    "Spins a orb"
                    "Infus <infus@squorn.de>"
                    "Infus"
                    "8.3.2016"
                    ""
                    SF-IMAGE "Image" 0
                    SF-DRAWABLE "Drawable" 0
                    SF-ADJUSTMENT "Rows" (list 16 1 128 1 10 0 SF-SPINNER)
                    SF-ADJUSTMENT "Columns" (list 16 1 128 1 10 0 SF-SPINNER))

(script-fu-register "script-fu-wa-noop"
                    "Duplicate Layers"
                    "Creates a grid"
                    "Infus <infus@squorn.de>"
                    "Infus"
                    "8.3.2016"
                    ""
                    SF-IMAGE "Image" 0
                    SF-DRAWABLE "Drawable" 0
                    SF-ADJUSTMENT "Rows" (list 16 1 128 1 10 0 SF-SPINNER)
                    SF-ADJUSTMENT "Columns" (list 16 1 128 1 10 0 SF-SPINNER))

(script-fu-register "script-fu-wa-duplicate-layer-once"
                    "Duplicate Layer to next frame"
                    ""
                    "Infus <infus@squorn.de>"
                    "Infus"
                    "8.3.2016"
                    ""
                    SF-IMAGE "Image" 0
                    SF-DRAWABLE "Drawable" 0
                    SF-ADJUSTMENT "Rows" (list 16 1 128 1 10 0 SF-SPINNER)
                    SF-ADJUSTMENT "Columns" (list 16 1 128 1 10 0 SF-SPINNER))

(script-fu-register "script-fu-wa-stroke-path"
                    "Paint Stroke along a Path"
                    ""
                    "Infus <infus@squorn.de>"
                    "Infus"
                    "8.3.2016"
                    ""
                    SF-IMAGE      "image"      0
                    SF-DRAWABLE "Drawable" 0
                    SF-ADJUSTMENT "Rows" (list 8 1 128 1 10 0 SF-SPINNER)
                    SF-ADJUSTMENT "Columns" (list 8 1 128 1 10 0 SF-SPINNER)
                    SF-ADJUSTMENT "Start Frame" (list 1 1 128 1 10 0 SF-SPINNER)
                    SF-ADJUSTMENT "End Frame" (list 64 1 255 1 10 0 SF-SPINNER)
                    SF-VECTORS    "Path to Stroke" -1
                    SF-ADJUSTMENT "Stroke Width" (list 5 0.1 100 1 10 1 SF-SLIDER)
                    SF-ADJUSTMENT "Spacing" (list 3 0.1 100 1 10 1 SF-SLIDER)
                    SF-OPTION     "Easing" wa-easing-functions-desc
                    )

(script-fu-menu-register "script-fu-wa-blur-horizontal" "<Image>/WA")
(script-fu-menu-register "script-fu-wa-blur-radial" "<Image>/WA")
(script-fu-menu-register "script-fu-wa-spotlight-horizontal" "<Image>/WA")
(script-fu-menu-register "script-fu-wa-spotlight-vertical" "<Image>/WA")
(script-fu-menu-register "script-fu-wa-spotlight-horizontal-word" "<Image>/WA")
(script-fu-menu-register "script-fu-wa-spotlight-vertical-word" "<Image>/WA")
(script-fu-menu-register "script-fu-wa-circle-mask" "<Image>/WA")
(script-fu-menu-register "script-fu-wa-spinning-orb" "<Image>/WA")
(script-fu-menu-register "script-fu-wa-noop" "<Image>/WA")
(script-fu-menu-register "script-fu-wa-duplicate-layer-once" "<Image>/WA")
(script-fu-menu-register "script-fu-wa-stroke-path" "<Image>/WA")