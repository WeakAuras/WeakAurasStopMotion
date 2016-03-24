(define (postproces-layer layer i x y)
  (gimp-drawable-set-visible layer 1)
  (gimp-layer-set-offsets layer x y)
  (gimp-layer-set-name layer (number->string i))
  )

(define (postproces-layers layer i x y)
  (if (list? layer)
    (map (lambda (l) (postproces-layer l i x y)) layer)
    (postproces-layer layer i x y)))

(define (script-fu-wa img layer rows columns function args)
    (define (create-layers i rows columns width height img layer function args)
       (let* ((newlayer (car (gimp-layer-new-from-drawable layer img)))
               (total (- (* rows columns) 1))
               (row (floor (/ i rows)))
               (col (remainder i columns))
              )
              (gimp-image-insert-layer img newlayer 0 -10)            
              (let* ((modifiedlayer (function img newlayer i total args)))
                (postproces-layers modifiedlayer i (* col width) (* row height)))
              (if (< i total) 
                (create-layers (+ i 1) rows columns width height img layer function args))
              ))
    
    (let* ((width (car (gimp-image-width img)))
           (height (car (gimp-image-height img))))    
        (gimp-undo-push-group-start img)
        (gimp-image-resize img (* (car (gimp-image-width img)) columns)
                               (* (car (gimp-image-height img)) rows)
                               0 0)
        (gimp-item-set-linked layer 0)
        (create-layers 0 rows columns width height img layer function args)
        (gimp-layer-set-visible layer 0)
        (gimp-undo-push-group-end img)
        (gimp-displays-flush)
    )
)

(define (wa-blur-horizontal img newlayer i total args)
  (let* ((blur-length (car args))
         (len (* (- (/ i total) 1) blur-length))
         (fade-in (cadr args))
         (opacity-until (or (and (= fade-in 1) (/ total 3)) -1))
         (opacity (or (and (< i opacity-until) (* (/ i opacity-until) 100)) 100))
         (width (car (gimp-drawable-width newlayer)))
         (height (car (gimp-drawable-height newlayer)))
         )
        (plug-in-mblur 1 img newlayer 0 len 0 (/ width 2) (/ height 2))
        (gimp-layer-set-opacity newlayer opacity))
        newlayer)

(define (wa-blur-radial img newlayer i total args)
  (let* ((max-blur (car args))
         (a (* (- (/ i total) 1) max-blur))
         (fade-in (cadr args))
         (opacity-until (or (and (= fade-in 1) (/ total 3)) -1))
         (opacity (or (and (< i opacity-until) (* (/ i opacity-until) 100)) 100))
         (width (car (gimp-drawable-width newlayer)))
         (height (car (gimp-drawable-height newlayer))))
        (plug-in-mblur 1 img newlayer 1 0 a (/ width 2) (/ height 2))
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
        (gimp-image-insert-layer img newlayer2 0 -10)
        (gimp-image-insert-layer img newlayer3 0 -10)
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
        (gimp-image-insert-layer img newlayer2 0 -10)
        (gimp-layer-set-mode newlayer2 16)
        (let* ((mask (car (gimp-layer-create-mask newlayer2 0))))
          (gimp-layer-add-mask newlayer2 mask)
          (gimp-edit-blend newlayer2 0 0 1 100 0 0 0 1 5 4 1 x1 0 x2 0))
        (gimp-context-set-background oldbackground)
        (gimp-context-set-foreground oldforeground)
        (car (gimp-image-merge-down img newlayer2 0))))
        
(define (wa-circle-mask img newlayer i total args)
  (let* ((width (car (gimp-drawable-width newlayer)))
          (height (car (gimp-drawable-height newlayer)))
          (mx (/ width 2))
          (my (/ height 2))
          (l (- 0 width))
          (t (- 0 height))
          (r (* 2 width))
          (b (* 2 height))
          (percent (/ i total))
          (pi (* 4 (atan 1.0)))
          (radians (* 2 pi percent))
          (s (* (sin radians) width 1.5))
          (c (* (cos radians) height 1.5))
          (path (car (gimp-vectors-new img "path"))))
        (gimp-image-insert-vectors img path 0 -1)
        (if (> i 0)
            (let* ((stroke (car (gimp-vectors-bezier-stroke-new-moveto path mx my))))
               (gimp-vectors-bezier-stroke-lineto path stroke mx t)
               (if (>= percent 0.25)
                 (gimp-vectors-bezier-stroke-lineto path stroke r my))
               (if (>= percent 0.50)
                 (gimp-vectors-bezier-stroke-lineto path stroke mx b))
               (if (>= percent 0.75)
                 (gimp-vectors-bezier-stroke-lineto path stroke l my))
               (gimp-vectors-bezier-stroke-lineto path stroke (+ mx s) (- my c))
               (gimp-vectors-bezier-stroke-lineto path stroke mx my)
               (gimp-image-select-item img 2 path)
               (let* ((mask (car (gimp-layer-create-mask newlayer 4))))
                   (gimp-layer-add-mask newlayer mask))
               (gimp-selection-none img)
               (gimp-image-remove-vectors img path))
            (let* ((mask (car (gimp-layer-create-mask newlayer 1))))
                   (gimp-layer-add-mask newlayer mask))))
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
        
(define (wa-noop img newlayer i total args)
  newlayer)

(define (script-fu-wa-blur-horizontal img layer rows columns blur-length fade-in)
   (script-fu-wa img layer rows columns wa-blur-horizontal (list blur-length fade-in)))
   
(define (script-fu-wa-blur-radial img layer rows columns max-blur fade-in)
   (script-fu-wa img layer rows columns wa-blur-radial (list max-blur fade-in)))
   
(define (script-fu-wa-spotlight-horizontal img layer rows columns highlight-width offset)
   (script-fu-wa img layer rows columns wa-spotlight-horizontal (list highlight-width offset)))
   
(define (script-fu-wa-spotlight-horizontal-word img layer rows columns highlight-width colored-width offset)
   (script-fu-wa img layer rows columns wa-spotlight-horizontal-word (list highlight-width colored-width offset)))
   
(define (script-fu-wa-circle-mask img layer rows columns)
   (script-fu-wa img layer rows columns wa-circle-mask '()))
   
(define (script-fu-wa-spinning-orb img layer rows columns)
   (script-fu-wa img layer rows columns wa-spinning-orb '()))
   
(define (script-fu-wa-noop img layer rows columns)
   (script-fu-wa img layer rows columns wa-noop '()))

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
                    SF-ADJUSTMENT "Blur Length" (list -45 -100 100 1 10 0 SF-SPINNER)
                    SF-TOGGLE "Fade In" TRUE)
                    
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
                    SF-ADJUSTMENT "Columns" (list 16 1 128 1 10 0 SF-SPINNER))
                    
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
                    "Duplicate Layer"
                    "Creates a grid"
                    "Infus <infus@squorn.de>"
                    "Infus"
                    "8.3.2016"
                    ""
                    SF-IMAGE "Image" 0
                    SF-DRAWABLE "Drawable" 0
                    SF-ADJUSTMENT "Rows" (list 16 1 128 1 10 0 SF-SPINNER)
                    SF-ADJUSTMENT "Columns" (list 16 1 128 1 10 0 SF-SPINNER))
                    
(script-fu-menu-register "script-fu-wa-blur-horizontal" "<Image>/WA")
(script-fu-menu-register "script-fu-wa-blur-radial" "<Image>/WA")
(script-fu-menu-register "script-fu-wa-spotlight-horizontal" "<Image>/WA")
(script-fu-menu-register "script-fu-wa-spotlight-horizontal-word" "<Image>/WA")
(script-fu-menu-register "script-fu-wa-circle-mask" "<Image>/WA")
(script-fu-menu-register "script-fu-wa-spinning-orb" "<Image>/WA")
(script-fu-menu-register "script-fu-wa-noop" "<Image>/WA")
       

