---
title: ML Training
description:
---
{% raw %}
<style>
  /* ML Storage Calculator styles */
  #ml-storage-calculator-app {
    font-family: Arial, sans-serif;
    margin: 2rem 0;
  }
  #ml-storage-calculator-app label {
    display: block;
    margin-top: 1rem;
  }
  #ml-storage-calculator-app input,
  #ml-storage-calculator-app select {
    margin-left: 0.5rem;
  }
  #ml-storage-calculator-app table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 2rem;
  }
  #ml-storage-calculator-app th,
  #ml-storage-calculator-app td {
    border: 1px solid #ccc;
    padding: 0.5rem;
    text-align: left;
  }
  #ml-storage-calculator-app th {
    background: #f5f5f5;
  }
</style>

<div id="ml-storage-calculator-app"></div>

<script src="https://unpkg.com/mithril/mithril.js"></script>
<script>
  // ML Storage Calculator injected into Jekyll markdown page
  (function() {
    const Calculator = {
      params: 8,
      scale: 'B',
      checkpoints: 1,
      corpus: 0,
      gpus: 16,
      storagePerGpu: 300,

      view() {
        const { params, scale, checkpoints, corpus, gpus, storagePerGpu } = Calculator;

        const p = Math.max(0, parseFloat(params) || 0);
        const cp = Math.max(0, parseFloat(checkpoints) || 0);
        const corp = Math.max(0, parseFloat(corpus) || 0);
        const ng = Math.max(0, parseFloat(gpus) || 0);
        const spg = Math.max(0, parseFloat(storagePerGpu) || 0);

        const scaleFactor = scale === 'M' ? 1e6 : 1e9;
        const modelSizeBytes = p * scaleFactor * 12;
        const totalModelBytes = modelSizeBytes * cp;
        const toTB = x => x / Math.pow(1024, 4);
        const corpusTB = corp / 1024;
        const sharedTB = (ng * spg) / 1024;
        const freeCap = sharedTB > 0 ? (sharedTB - (toTB(totalModelBytes) + corpusTB)) / sharedTB : 0;

        return m("div#ml-storage-calculator-app", [
          m("h1", "ML Storage Calculator"),
          m("label", "Number of parameters:",
            m("input[type=number][min=0][step=1]", { value: params, oninput: e => Calculator.params = e.target.value })
          ),
          m("label", "Parameter scaling:",
            m("select", { value: scale, onchange: e => Calculator.scale = e.target.value }, [
              m("option[value=M]", 'Millions (M)'),
              m("option[value=B]", 'Billions (B)')
            ])
          ),
          m("label", "Retained checkpoints:",
            m("input[type=number][min=0][step=1]", { value: checkpoints, oninput: e => Calculator.checkpoints = e.target.value })
          ),
          m("label", "Training corpus size (GB):",
            m("input[type=number][min=0][step=0.01]", { value: corpus, oninput: e => Calculator.corpus = e.target.value })
          ),
          m("label", "Number of GPUs:",
            m("input[type=number][min=0][step=1]", { value: gpus, oninput: e => Calculator.gpus = e.target.value })
          ),
          m("label", "Storage per GPU (GB):",
            m("input[type=number][min=0][step=1]", { value: storagePerGpu, oninput: e => Calculator.storagePerGpu = e.target.value })
          ),

          m("table", [
            m("thead", m("tr", [ m("th", "Metric"), m("th", "Value") ])),
            m("tbody", [
              m("tr", [ m("td", "Total shared storage"), m("td", (sharedTB).toFixed(3) + " TB") ]),
              m("tr", [ m("td", "Total required storage"), m("td", (toTB(totalModelBytes) + corpusTB).toFixed(3) + " TB") ]),
              m("tr", [ m("td", "Free capacity"), m("td", (freeCap * 100).toFixed(2) + "%") ])
            ])
          ])
        ]);
      }
    };

    // mount into the Jekyll page element
    m.mount(document.getElementById('ml-storage-calculator-app'), Calculator);
  })();
</script>
{% endraw %}
