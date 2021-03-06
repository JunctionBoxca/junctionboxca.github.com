---
title:      Reagent Container Components
created_at: 2016-09-03 12:00:00 +00:00
layout:     default
published: true
description: In this article I cover off how I've adapted the React/Redux Presentational and Container Component pattern to ClojureScript using Reagent and Re-Frame.
keywords: clojurescript,re-frame,reagent
tags: clojure
---

If you've used [React Redux](http://redux.js.org/docs/basics/UsageWithReact.html) you've likely come across the Presentation and Container Component pattern. A similar pattern can be achieved with [Reagent](https://reagent-project.github.io) and [Re-frame](https://github.com/Day8/re-frame). The primary motivation to use this pattern is creating a clear separation of concerns. The presentational component renders the view from it's properties and is ideally a pure function which makes it easy to test. The container component subscribes to updates made in the re-frame app-db.

To recap here's a few definitions:

<dl>
<dt>
ClojureScript

</dt>
<dd>
A [Clojure](https://clojure.org/) to Javascript transpiler that leverages Google Closure to generate super small JS files.

</dd>
<dt>
Reagent

</dt>
<dd>
React bindings for use with ClojureScript.

</dd>
<dt>
Re-frame

</dt>
<dd>
Reactive datastore framework for use with ClojureScript which provides similar facilities as Redux via a specialised atom called app-db.

</dd>
<dt>
Presentational Component

</dt>
<dd>
Encapsulates visual elements. Approximately the V in MVC.

</dd>
<dt>
Container Component

</dt>
<dd>
Encapsulates logical functionality such as state updates and web requests. Approximately the C in MVC.

</dd>
</dl>
Ok so there's a few things you'll need before we get started:

- Java 1.8.

- leiningen 2.6.2 - see [install leiningen](http://leiningen.org/#install).

- new project workspace <code>mkdir -p ${WORKSPACE}/cljs-reagent-reframe</code>
- optionally you can clone my [cljs-reagent-reframe](https://github.com/nfisher/cljs-reagent-reframe) repo.

### Creating a Minimal Project

With the above out of the way we can get started. The first thing we need to do is gather all of the dependencies. Starting with the re-frame [simple](https://github.com/Day8/re-frame/tree/master/examples/simple) project as a base the following project.clj specifies the minimum dependencies required to build our project:

```clojure
cat > ${WORKSPACE}/cljs-reagent-reframe/project.clj <<EOT
(defproject cljs-reagent-reframe "0.8.0"
  :dependencies [[org.clojure/clojure        "1.8.0"]
                  [org.clojure/clojurescript  "1.9.227"]
                  [reagent  "0.6.0-rc"]
                  [re-frame "0.8.0"]]

  :plugins [[lein-cljsbuild "1.1.4"]
            [lein-figwheel  "0.5.6"]]

  :hooks [leiningen.cljsbuild]

  :profiles {:dev {:cljsbuild
                    {:builds {:client {:source-paths ["env/dev/cljs"]
                                      :compiler     {:main "crr.dev"
                                                      :asset-path "js"
                                                      :optimizations :none
                                                      :source-map true
                                                      :source-map-timestamp true}}}}}

              :prod {:cljsbuild
                    {:builds {:client {:compiler    {:optimizations :advanced
                                                      :elide-asserts true
                                                      :pretty-print false}}}}}}

  :figwheel {:repl false}

  :clean-targets ^{:protect false} ["resources/public/js"]

  :cljsbuild {:builds {:client {:source-paths ["src"]
                                :compiler     {:output-dir "resources/public/js"
                                                :output-to  "resources/public/js/client.js"}}}})
EOT
```

The keen observer will note a few folders in the above project need to be created:

```bash
mkdir -p ${WORKSPACE}/cljs-reagent-reframe/env/dev/cljs/crr
mkdir -p ${WORKSPACE}/cljs-reagent-reframe/resources/public/js
mkdir -p ${WORKSPACE}/cljs-reagent-reframe/src/cljs/crr
cd ${WORKSPACE}/cljs-reagent-reframe
```

Next up is a little bit of figwheel love for hot reloads in the browser:

```clojure
cat > env/dev/cljs/crr/dev.cljs <<EOT
(ns crr.dev
  (:require [crr.core :as crr]
            [figwheel.client :as fw]))

(enable-console-print!)

(fw/start {:on-jsload crr/run
            :websocket-url "ws://localhost:3449/figwheel-ws"})
EOT
```

Now a minimal skeleton app including a reagent component:

```clojure
cat > src/cljs/crr/core.cljs <<EOT
(ns crr.core
  (:require [reagent.core :as reagent]))

(defn hello-world []
  [:h1 "Hello World"]) ; instead of JSX, Reagent uses Hiccup which is nested vectors.

(defn ^:export run
  []
  (reagent/render [hello-world] ; hiccup that renders hello-world into page
                  (js/document.getElementById "app")))
EOT
```

You can check everything is ok by running:

<code>lein do clean, figwheel</code>

You should see an output similar to the following:

    Figwheel: Cutting some fruit, just a sec ...
    Figwheel: Validating the configuration found in project.clj
    Figwheel: Configuration Valid :)
    Figwheel: Starting server at http://0.0.0.0:3449
    Figwheel: Watching build - client
    Figwheel: Cleaning build - client
    Compiling "resources/public/js/client.js" from ("src" "env/dev/cljs")...
    Successfully compiled "resources/public/js/client.js" in 9.909 seconds.

Ok great but that doesn't really do much. We need a web page to take advantage of the magic:

    cat > resources/public/index.html <<EOT
    <!doctype html>
    <head>
    <meta charset="utf-8">
    <title>Reagent and Re-Frame Luv</title>
    </head>
    <body>
    <div id="app">
    <p>Loading App...</p>
    </div>
    <script src="/js/client.js"></script>
    <script>
    window.onload = function () {
      crr.core.run();
    }
    </script>
    </body>
    EOT

Starting up figwheel again we can browse the newly created HTML:

<code>lein do clean, figwheel</code>

Once you see the JS has been successfully compiled fire up <http://localhost:3449/>. Boom! You should see "Hello World" displayed in your browser. If you're not seeing "Hello World" open your browser [console](https://developers.google.com/web/tools/chrome-devtools/debug/console/console-ui?hl=en) and check for 404's assets and/or JavaScript errors.

### Reagent Presentational Component

Now let's convert hello-world into a presentational component with the following change to core.cljs:

```clojure
(defn hello-world [name] ; accept name as a parameter
  [:h1 "Hello " name]) ; instead of JSX, Reagent uses Hiccup which are simply nested vectors.

(defn ^:export run
  []
  (reagent/render [hello-world "World 2"] ; hiccup that renders hello-world into page
                  (js/document.getElementById "app")))
```

### Reagent Container Component

Now my kind reader you might be scratching your head..."thought you said there's hot reloads!! I want a refund!!". Well patience my friend let's introduce the container:

```clojure
(defn hello-world-container []
  ;; our container
  (let [name "World 3"]
    (fn []
      [hello-world name])))

(defn ^:export run
  []
  (reagent/render [hello-world-container ] ; hiccup that renders hello-world into page
                  (js/document.getElementById "app")))
```

"Dude this still isn't auto-loading!!" Ok refresh your browser and stay with me. To reward your patience change the name string in the container as follows:

```clojure
(defn hello-world-container []
  ;; our container
  (let [name "World 4"]
    (fn []
      [hello-world name])))
```

Huzzah! Live loading! That's the reagent container and presentational container mostly done.

### Re-Frame Database Initialisation

Let's sprinkle in a side of re-frame by initialising the database (re-frame.db/app-db).

**Note**: This is prep work that won't have a visible side-effect yet!

Import re-frame:

```clojure
(ns crr.core
  (:require [reagent.core :as reagent]
            [re-frame.core :as rf]))
```

Define the initial state and add the initialisation handler:

```clojure
(def initial-state
  {:name "World 5"}) ; this is the map we want to initialise the app-db to.

(rf/reg-event-db
  :initialise
  (fn [db _]
    (merge db initial-state)))
```

Initialise the database:

```clojure
(defn ^:export run
      []
      (rf/dispatch-sync [:initialise])
      (reagent/render [hello-world-container ] ; hiccup that renders hello-world into page
                      (js/document.getElementById "app")))</code>
```

Hit refresh and you'll still see "Hello World 4". What you've likely noticed is that any behaviour which isn't contained in the render scope requires a refresh of the web page.

### Re-Frame Database Subscription

Next let's add a subscription to read from the app-db:

```clojure
(rf/reg-sub
  :name
  (fn [db arg]
    (println "pirate sayz " arg) ; you should see the subscription vector in the console
    (:name db)))

(defn hello-world-container []
  ;; our container
  (let [name (rf/subscribe [:name])] ; the subscribe takes a vector allowing subscription to a deeply nested value in app-db.
    (fn []
      [hello-world @name]))) ; note we're de-referencing the atom here</code>
```

### Adding an Input

Ok so we've got it reading from the app-db. How do we write? Let's add a simple input to the component:

```clojure
(defn hello-world [name] ; accept name as a parameter
  [:div
    [:input {:type :text}]
    [:h1 "Hello " name]]) ; instead of JSX, Reagent uses Hiccup which are simply nested vectors.</code>
```

### Re-Frame Dispatching

Add a handler and link it to the input as follows:

```clojure
(defn update-name [db [_ new-name]] ; re-frame examples use anonymous functions. Using a named function allows for easier testing.
  (merge db {:name new-name}))

(rf/reg-event-db
  :name-changed
  update-name)

(defn change-name [evt]
  (rf/dispatch-sync [:name-changed (-> evt .-target .-value)]))

(defn hello-world [name] ; accept name as a parameter
  [:div
    [:input {:type :text :on-change change-name :value name}]
    [:h1 "Hello " name]]) ; instead of JSX, Reagent uses Hiccup which are simply nested vectors.</code>
```

You now have the ability to update the title via the input field. The ":value name" pair can be omitted but demonstrates two way binding.

### Tips and Tricks

Some general tips I've found during my own development:

-   make presentational components pure functions to ease testing.
-   make handlers pure named functions to ease testing.
-   avoid subscriptions in presentational components.
-   dereference atoms outside the presentational component.
-   link ownership of values in app-db with the container using a nested map (e.g. {:container-ns {:field "Value"}}).
-   defer "DRY"-ing handlers, containers and components until you've implemented at least 3 clear duplicates.
-   use dispatch-sync for input fields to prevent an unusual user experience (e.g. unexpected resetting of cursor position).
-   use dispatch for buttons and selects as it's asynchronous nature doesn't impact user interactions.
-   prefer specific symbols for event handlers and subscriptions rather than generic ones (e.g. :address-changed over :input-changed).

Some practises others have suggested:

-   use cljs.spec to enforce structural constraints on key/values held within app-db.
