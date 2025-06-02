---
title: ML Training Storage Calculator
description: ML Training Storage Calculator
layout: default
permalink: /resources/mltraining/
nocomment:  true
---
{% raw %}
<style>
  /* ML Storage Calculator styles (inheriting page defaults) */
  #ml-storage-calculator-app {
    margin: 2rem 0;
    max-width: 600px;
    background: #fff;
    border: 1px solid #e0e0e0;
    border-radius: 8px;
    padding: 1.5rem;
    box-shadow: 0 2px 5px rgba(0,0,0,0.1);
  }
  #ml-storage-calculator-app .fieldsets-container {
    display: flex;
    justify-content: space-between;
    gap: 1rem;
    margin-bottom: 1.5rem;
  }
  #ml-storage-calculator-app fieldset {
    flex: 1;
    border: 1px solid #ccc;
    border-radius: 6px;
    padding: 1rem 1.5rem;
    background: #fafafa;
  }
  #ml-storage-calculator-app legend {
    font-weight: bold;
    padding: 0 0.5rem;
    background: #f5f5f5;
    border-radius: 4px;
  }
  #ml-storage-calculator-app .field {
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    margin-top: 1rem;
  }
  #ml-storage-calculator-app label {
    margin-bottom: 0.5rem;
    color: #333;
  }
  #ml-storage-calculator-app input,
  #ml-storage-calculator-app select {
    width: 100%;
    max-width: 200px;
    padding: 0.5rem;
    border: 1px solid #bbb;
    border-radius: 4px;
    transition: border-color 0.2s;
  }
  #ml-storage-calculator-app input:focus,
  #ml-storage-calculator-app select:focus {
    border-color: #007acc;
    outline: none;
    box-shadow: 0 0 3px rgba(0,122,204,0.3);
  }
  #ml-storage-calculator-app table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 1.5rem;
  }
  #ml-storage-calculator-app th,
  #ml-storage-calculator-app td {
    border: 1px solid #ddd;
    padding: 0.75rem;
    text-align: left;
  }
  #ml-storage-calculator-app th {
    background: #f0f0f0;
    font-weight: bold;
  }
  #ml-storage-calculator-app tr:nth-child(even) {
    background: #fafafa;
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
      checkpoints: 10,
      corpus: 20,
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
        const requiredTB = toTB(totalModelBytes) + corpusTB;
        const freeCap = sharedTB > 0 ? (sharedTB - requiredTB) / sharedTB : 0;

        return m("div#ml-storage-calculator-app", [
          m("div.fieldsets-container", [
            m("fieldset", [
              m("legend", "Infrastructure"),
              m("div.field", [
                m("label", "Number of GPUs:"),
                m("input[type=number][min=0][step=1]", { value: gpus, oninput: e => Calculator.gpus = e.target.value })
              ]),
              m("div.field", [
                m("label", "Storage per GPU (GB):"),
                m("input[type=number][min=0][step=1]", { value: storagePerGpu, oninput: e => Calculator.storagePerGpu = e.target.value })
              ])
            ]),
            m("fieldset", [
              m("legend", "Model"),
              m("div.field", [
                m("label", "Number of parameters:"),
                m("input[type=number][min=0][step=1]", { value: params, oninput: e => Calculator.params = e.target.value })
              ]),
              m("div.field", [
                m("label", "Parameter scaling:"),
                m("select", { value: scale, onchange: e => Calculator.scale = e.target.value }, [
                  m("option[value=M]", "Millions (M)"),
                  m("option[value=B]", "Billions (B)")
                ])
              ]),
              m("div.field", [
                m("label", "Retained checkpoints:"),
                m("input[type=number][min=0][step=1]", { value: checkpoints, oninput: e => Calculator.checkpoints = e.target.value })
              ]),
              m("div.field", [
                m("label", "Training corpus size (GB):"),
                m("input[type=number][min=0][step=0.01]", { value: corpus, oninput: e => Calculator.corpus = e.target.value })
              ])
            ])
          ]),
          m("table", [
            m("thead", m("tr", [ m("th", "Metric"), m("th", "Value") ])),
            m("tbody", [
              m("tr", [ m("td", "Total shared storage"), m("td", sharedTB.toFixed(3) + " TB") ]),
              m("tr", [ m("td", "Total required storage"), m("td", requiredTB.toFixed(3) + " TB") ]),
              m("tr", [ m("td", "Free capacity"), m("td", (freeCap * 100).toFixed(2) + "%") ])
            ])
          ])
        ]);
      }
    };

    m.mount(document.getElementById('ml-storage-calculator-app'), Calculator);
  })();
</script>
{% endraw %}
