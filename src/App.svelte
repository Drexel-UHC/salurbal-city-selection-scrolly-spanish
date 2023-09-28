<!-- 
  # ============================================================================ #
  #  ............... script ...............
-->

<script>
  // Scrolly stuff
  import { onMount } from 'svelte';
  import Scroller from './layout/Scroller.svelte';
  import {
    Map,
    MapSource,
    MapLayer,
    MapTooltip,
    MapPopup,
  } from '../libs/@onsvisual/svelte-maps';
  import { getData, getColor, getTopo, getJson } from './utils.js';
  import bbox from '@turf/bbox';

  // Layout
  import { setContext } from 'svelte';
  import { themes } from './config.js';
  import { setColors } from './utils.js';
  import { colors } from './config.js';
  import UHCHeader from './layout/UHCHeader.svelte';
  import UHCFooter from './layout/UHCFooter.svelte';
  import Header from './layout/Header.svelte';
  import Section from './layout/Section.svelte';
  import Media from './layout/Media.svelte';
  import Filler from './layout/Filler.svelte';
  import Divider from './layout/Divider.svelte';
  import Toggle from './ui/Toggle.svelte';
  import Arrow from './ui/Arrow.svelte';

  import { initSuperflow } from '@usesuperflow/client';
  initSuperflow('t3p1NHY1MaAX795EXt7m', {
    projectId: '501229561750262',
  });

  let theme = 'light';
  setContext('theme', theme);
  setColors(themes, theme);

  // # ============================================================================ #
  // Map Objects

  // Bindings
  let map_static_1;
  let map_scrolly_1;
  let map_scrolly_2;

  // Colors
  const hex_primary = '#2F8FBC';
  const hex_secondary = '#00BB9E';
  const hex_error = '#BC3B2F';
  const hex_warning = '#BC812F';
  const hex_teal = '#00BB9E';
  const hex_background = '#d8e6ed';
  const hex_purple = '#8C198C';
  const hex_green = '#305145';

  const bounds = {
    southAmerica: [
      [-117.157278, -55.058347], // Southwest coordinates
      [-66.273339, 34], // Northeast coordinates
    ],
    southAmericaShifted: [
      [-97.157278, -55.058347], // Southwest coordinates (shifted)
      [-46.273339, 34], // Northeast coordinates (shifted)
    ],
    municipio: [
      [-46.826191, -24.008374],
      [-46.365357, -23.357529],
    ],
    metro: [
      [-47.2054645, -24.0642507],
      [-45.6952955, -23.184244],
    ],
    l1ad: [
      [-47.084742, -24.008374],
      [-46.051954, -23.183419],
    ],
    ex_l2: [
      [-46.584936, -23.650164],
      [-46.544989, -23.600327],
    ],
    monterrey: [
      [-100.8619014, 25.2237859], // Southwest coordinates
      [-99.6864261, 26.3951673], // Northeast coordinates
    ],
    rio_cuarto: [
      [-65.1437809, -34.2456892], // Southwest coordinates
      [-63.8864557, -32.3048849], // Northeast coordinates
    ],
  };

  // Data

  // State
  let zoom;
  let center = {};
  let hovered, selected;

  // # ============================================================================ #
  // Import Data

  // All Salurbal L1 centroids
  const src__salurbal_centroid = {
    url: './data/salurbal_l1ad_centroid.json',
    layer: 'geog',
    code: 'salid2',
  };
  let geojson_salurbal_centroid;
  getTopo(src__salurbal_centroid.url, src__salurbal_centroid.layer).then(
    (res) => {
      geojson_salurbal_centroid = res;
    }
  );

  // municipio centroid
  const src__municipio_centroid = {
    url: './data/sao_paolo_municipio_centroid.json',
    layer: 'geog',
    code: 'salid2',
  };
  let geojson_municipio_centroid;
  getTopo(src__municipio_centroid.url, src__municipio_centroid.layer).then(
    (res) => {
      geojson_municipio_centroid = res;
    }
  );

  // L1AD centroid
  let sao_paolo_l1ad_centroid;
  getJson('./data/sao_paolo_l1ad_centroid.json').then((res) => {
    sao_paolo_l1ad_centroid = res;
  });

  // Municipio boundaries
  const src_municipio = {
    url: './data/sao_paolo_municipio.json',
    layer: 'geog',
    code: 'salid2',
  };
  let geojson_municipio;
  getTopo(src_municipio.url, src_municipio.layer).then((res) => {
    geojson_municipio = res;
  });

  // Metropolitan boundaries
  const src_metro = {
    url: './data/sao_paolo_metro.json',
    layer: 'geog',
    code: 'salid2',
  };
  let geojson_metro;
  getTopo(src_metro.url, src_metro.layer).then((res) => {
    geojson_metro = res;
  });

  // L1UX boundaries
  const src_l1ux = {
    url: './data/sao_paolo_l1ux.json',
    layer: 'geog',
    code: 'salid1',
  };
  let geojson_l1ux;
  getTopo(src_l1ux.url, src_l1ux.layer).then((res) => {
    geojson_l1ux = res;
  });

  // L1AD boundaries
  const src_l1ad = {
    url: './data/sao_paolo_l1ad.json',
    layer: 'geog',
    code: 'salid1',
  };
  let geojson_l1ad;
  getTopo(src_l1ad.url, src_l1ad.layer).then((res) => {
    geojson_l1ad = res;
  });

  // L2 boundaries
  const src_l2 = {
    url: './data/sao_paolo_l2.json',
    layer: 'geog',
    code: 'salid2',
  };
  let geojson_l2;
  getTopo(src_l2.url, src_l2.layer).then((res) => {
    geojson_l2 = res;
  });

  // L25 boundaries
  const src_l25 = {
    url: './data/sao_paolo_l25.json',
    layer: 'geog',
    code: 'salid2',
  };
  let geojson_l25;
  getTopo(src_l25.url, src_l25.layer).then((res) => {
    geojson_l25 = res;
  });

  // L3 boundaries
  const src_l3 = {
    url: './data/sao_paolo_l3.json',
    layer: 'geog',
    code: 'salid2',
  };
  let geojson_l3;
  getTopo(src_l3.url, src_l3.layer).then((res) => {
    geojson_l3 = res;
  });

  // Example L2 boundaries (L2: 10224830 'sao-caetano-do-sul')
  const src_ex_l2 = {
    url: './data/sao_paolo_ex_l2.json',
    layer: 'geog',
    code: 'salid2',
  };
  let geojson_ex_l2;
  getTopo(src_ex_l2.url, src_ex_l2.layer).then((res) => {
    geojson_ex_l2 = res;
  });

  // ex_l25 boundaries
  const src_ex_l25 = {
    url: './data/sao_paolo_ex_l25.json',
    layer: 'geog',
    code: 'salid2',
  };

  let geojson_ex_l25;
  getTopo(src_ex_l25.url, src_ex_l25.layer).then((res) => {
    geojson_ex_l25 = res;
  });

  // ex_l3 boundaries
  const src_ex_l3 = {
    url: './data/sao_paolo_ex_l3.json',
    layer: 'geog',
    code: 'salid2',
  };

  let geojson_ex_l3;
  getTopo(src_ex_l3.url, src_ex_l3.layer).then((res) => {
    geojson_ex_l3 = res;
  });

  // Case 1 (monterrey) L1UX boundaries
  const src_monterrey_l1ux = {
    url: './data/monterrey_l1ux.json',
    layer: 'geog',
    code: 'salid1',
  };
  let geojson_monterrey_l1ux;
  getTopo(src_monterrey_l1ux.url, src_monterrey_l1ux.layer).then((res) => {
    geojson_monterrey_l1ux = res;
  });

  // Case 1 (Monterrey) L1AD boundaries
  const src_monterrey_l1ad = {
    url: './data/monterrey_l1ad.json',
    layer: 'geog',
    code: 'salid1',
  };
  let geojson_monterrey_l1ad;
  getTopo(src_monterrey_l1ad.url, src_monterrey_l1ad.layer).then((res) => {
    geojson_monterrey_l1ad = res;
  });

  // Case 1 (Monterrey) unbuilt boundaries
  const src_monterrey_unbuilt = {
    url: './data/monterrey_unbuilt.json',
    layer: 'geog',
    code: 'salid1',
  };
  let geojson_monterrey_unbuilt;
  getTopo(src_monterrey_unbuilt.url, src_monterrey_unbuilt.layer).then(
    (res) => {
      geojson_monterrey_unbuilt = res;
    }
  );

  // Case 1 (Monterrey) l2 boundaries
  const src_monterrey_l2 = {
    url: './data/monterrey_l2.json',
    layer: 'geog',
    code: 'salid1',
  };
  let geojson_monterrey_l2;
  getTopo(src_monterrey_l2.url, src_monterrey_l2.layer).then((res) => {
    geojson_monterrey_l2 = res;
  });

  // Case 2 (Rio Cuarto) L1AD boundaries
  const src_rio_cuarto_l1ad = {
    url: './data/rio_cuarto_l1ad.json',
    layer: 'geog',
    code: 'salid1',
  };
  let geojson_rio_cuarto_l1ad;
  getTopo(src_rio_cuarto_l1ad.url, src_rio_cuarto_l1ad.layer).then((res) => {
    geojson_rio_cuarto_l1ad = res;
  });

  // Case 2 (Rio Cuarto) L1UX boundaries
  const src_rio_cuarto_l1ux = {
    url: './data/rio_cuarto_l1ux.json',
    layer: 'geog',
    code: 'salid1',
  };
  let geojson_rio_cuarto_l1ux;
  getTopo(src_rio_cuarto_l1ux.url, src_rio_cuarto_l1ux.layer).then((res) => {
    geojson_rio_cuarto_l1ux = res;
  });
  // Case 2 (Rio Cuarto) l2 boundaries
  const src_rio_cuarto_l2 = {
    url: './data/rio_cuarto_l2.json',
    layer: 'geog',
    code: 'salid1',
  };
  let geojson_rio_cuarto_l2;
  getTopo(src_rio_cuarto_l2.url, src_rio_cuarto_l2.layer).then((res) => {
    geojson_rio_cuarto_l2 = res;
  });

  // Functions for map component
  function fitBounds(map, bounds) {
    if (map) {
      map.fitBounds(bounds, { animate: true, padding: 30 });
    }
  }
  function fitById(id) {
    if (geojson && id) {
      let feature = geojson.features.filter(
        (d) => d.properties.AREANM == id
      )[0];
      let bbox_tmp = bbox(feature.geometry);

      fitBounds(bbox_tmp);
    }
  }

  // # Scroller Setup
  const threshold = 0.65;
  let id = {}; // Object to hold visible section IDs of Scroller components
  let idPrev = {}; // Object to keep track of previous IDs, to compare for changes
  onMount(() => {
    idPrev = { ...id };
  });
  function runActions(codes = []) {
    //// Code to run Scroller actions when new caption IDs come into view
    codes.forEach((code) => {
      if (id[code] != idPrev[code]) {
        // if caption id changes then run then run following code to update chart
        if (actions[code][id[code]]) {
          actions[code][id[code]]();
        }
        idPrev[code] = id[code];
      }
    });
  }

  $: {
    // Run above code when 'id' object changes
    if (id) {
      runActions(Object.keys(actions));
    }
  }

  // # ============================================================================ #
  // Scroller Action

  // initial step
  const custom_1_map01 = {
    mapid: 'map01',
    layers: {
      municipio_centroid: {
        'circle-color': hex_error,
        'circle-radius': 7,
        'circle-stroke-color': hex_error,
        'circle-stroke-width': 1,
      },
      sp_popup: true,
    },
  };
  const custom_2_map01 = {
    mapid: 'map01',
    layers: {
      l2_line: {
        'line-color': hex_primary,
        'line-width': 2,
        'line-opacity': 1,
      },
      l2_fill: {
        'fill-color': hex_error,
        'fill-opacity': 0.5,
      },
      l1ad_line: {
        'line-color': hex_error,
        'line-width': 5,
      },
    },
  };

  let custom_1 = custom_1_map01;
  let custom_2 = custom_2_map01;

  // actions to update steps
  let actions = {
    map_scrolly_1: {
      map01: () => {
        fitBounds(map_scrolly_1, bounds.southAmerica);
        custom_1 = custom_1_map01;
      },
      map02: () => {
        fitBounds(map_scrolly_1, bounds.l1ad);
        custom_1 = {
          mapid: 'map02',
          layers: {
            l2_line: {
              'line-color': hex_primary,
              'line-width': 5,
            },
          },
        };
      },
      map04: () => {
        fitBounds(map_scrolly_1, bounds.l1ad);
        custom_1 = {
          mapid: 'map04',
          layers: {
            l1ux: {
              'line-color': hex_warning,
              'line-width': 5,
            },
            l2_line: {
              'line-color': hex_primary,
              'line-width': 2,
              'line-opacity': 1,
            },
            l2_fill: {
              'fill-color': hex_warning,
              'fill-opacity': 0.5,
            },
          },
        };
      },
      map05: () => {
        fitBounds(map_scrolly_1, bounds.l1ad);
        custom_1 = {
          mapid: 'map05',
          layers: {
            l2_line: {
              'line-color': hex_primary,
              'line-width': 2,
              'line-opacity': 1,
            },
            l2_fill: {
              'fill-color': hex_error,
              'fill-opacity': 0.5,
            },
            l1ad_line: {
              'line-color': hex_error,
              'line-width': 5,
            },
          },
        };
      },
      map06: () => {
        fitBounds(map_scrolly_1, bounds.monterrey);
        custom_1 = {
          mapid: 'map06',
          layers: {
            monterrey_l1ad_line: {
              'line-color': hex_error,
              'line-width': 4,
            },
            monterrey_l1ux_line: {
              'line-color': 'black',
              'line-width': 1,
              'line-opacity': 0.5,
            },
            monterrey_unbuilt_fill: {
              'fill-color': hex_teal,
              'fill-opacity': 0.2,
            },
            monterrey_l2_line: {
              'line-color': hex_primary,
              'line-width': 1.5,
            },
          },
        };
      },
      map07: () => {
        fitBounds(map_scrolly_1, bounds.rio_cuarto);
        custom_1 = {
          mapid: 'map07',
          layers: {
            rio_cuarto_l2_line: {
              'line-color': hex_primary,
              'line-width': 1.5,
            },
            rio_cuarto_l1ad_line: {
              'line-color': hex_error,
              'line-width': 6,
            },
            rio_cuarto_l1ad_fill: {
              'fill-color': hex_error,
              'fill-opacity': 0.25,
            },
            rio_cuarto_l1ux_line: {
              'line-color': hex_warning,
              'line-width': 2,
            },
          },
        };
      },
      map08: () => {
        fitBounds(map_scrolly_1, bounds.metro);
        custom_1 = {
          mapid: 'map08',
          layers: {
            municipio_line: {
              'line-color': hex_primary,
              'line-width': 3,
            },
            metro_line: {
              'line-color': hex_purple,
              'line-width': 4,
            },
            l1_fill: {
              'fill-color': hex_error,
              'fill-opacity': 0.3,
            },
            l1ad_line: {
              'line-color': hex_error,
              'line-width': 6,
            },
          },
        };
      },
    },
    map_scrolly_2: {
      map01: () => {
        fitBounds(map_scrolly_2, bounds.l1ad);
        custom_2 = custom_2_map01;
      },
      map02: () => {
        fitBounds(map_scrolly_2, bounds.l1ad);
        custom_2 = {
          mapid: 'map02',
          layers: {
            l2_line: {
              'line-color': hex_primary,
              'line-width': 5,
              'line-opacity': 1,
            },
            l2_fill: {
              'fill-color': hex_error,
              'fill-opacity': 0.15,
            },
            l1ad_line: {
              'line-color': hex_error,
              'line-width': 7,
              'line-opacity': 1,
            },
          },
        };
      },
      map03: () => {
        fitBounds(map_scrolly_2, bounds.l1ad);
        custom_2 = {
          mapid: 'map03',
          layers: {
            l2_line: {
              'line-color': hex_primary,
              'line-width': 5,
              'line-opacity': 1,
            },
            l2_fill: {
              'fill-color': hex_error,
              'fill-opacity': 0.1,
            },
            l1ad_line: {
              'line-color': hex_error,
              'line-width': 7,
              'line-opacity': 1,
            },
            l3_line: {
              'line-color': hex_secondary,
              'line-width': 0.2,
              'line-opacity': 1,
            },
          },
        };
      },
      map04: () => {
        fitBounds(map_scrolly_2, bounds.ex_l2);
        custom_2 = {
          mapid: 'map04',
          layers: {
            ex_l3: {
              'line-color': hex_teal,
              'line-width': 2,
            },
            ex_l2: {
              'line-color': hex_primary,
              'line-width': 8,
            },
          },
        };
      },
      map04: () => {
        fitBounds(map_scrolly_2, bounds.ex_l2);
        custom_2 = {
          mapid: 'map04',
          layers: {
            ex_l3: {
              'line-color': hex_teal,
              'line-width': 2,
            },
            ex_l2: {
              'line-color': hex_primary,
              'line-width': 8,
            },
          },
        };
      },
      map05: () => {
        fitBounds(map_scrolly_2, bounds.ex_l2);
        custom_2 = {
          mapid: 'map04',
          layers: {
            ex_l3: {
              'line-color': hex_teal,
              'line-width': 2,
            },
            ex_l25: {
              'line-color': hex_purple,
              'line-width': 4,
            },
            ex_l2: {
              'line-color': hex_primary,
              'line-width': 8,
            },
          },
        };
      },
      map06: () => {
        fitBounds(map_scrolly_2, bounds.l1ad);
        custom_2 = {
          mapid: 'map04',
          layers: {
            l1ad_line: {
              'line-color': hex_error,
              'line-width': 6,
              'line-opacity': 1,
            },
            l2_line: {
              'line-color': hex_primary,
              'line-width': 4,
            },
            l25_line: {
              'line-color': hex_purple,
              'line-width': 2,
            },
          },
        };
      },
    },
  };

  const style_l3 = `color: ${hex_teal}; font-weight: 900;`;
  const style_l2 = `color: ${hex_primary}; font-weight: 900;`;
  const style_l25 = `color: ${hex_purple}; font-weight: 900;`;
  const style_ux = `color: ${hex_warning}; font-weight: 900;`;
  const style_l1 = `color: ${hex_error}; font-weight: 900;`;
  const style_unurban = `color: ${hex_teal}; font-weight: 900;`;
  const style_metro = `color: ${hex_purple}; font-weight: 900;`;
</script>

<!-- 
  # ============================================================================ #
  #  ............... markup ...............
-->
<!-- <div class="stickDev">
  {id.map_scrolly_1}
  {id.map_scrolly_2}
</div> -->
<UHCHeader filled={true} center={false} />

<Filler theme="lightblue" short={true} wide={true} center={false}>
  <h1>¿Qué es una ciudad SALURBAL?</h1>
  <p class="text-big" style="margin-top: 5px">
    Definición y selección de ciudad, sub-ciudad y barrio SALURBAL
  </p>

  <p class="text-medium">
    Diseñado por: <span style={'font-weight: 900'}>
      Usama Bilal, Katy Indvik, Steve Melly, Andrea Bolinaga, Kari Moore, Alex
      Quistberg, Ana V. Diez Roux</span
    >
    <br />
    Desarrollado por:
    <span style={'font-weight: 900'}> Anuj Tanwar, Ran Li</span>
  </p>
</Filler>

<Section>
  <h2>Introducción</h2>
  <p class="text-medium">
    El equipo de SALURBAL ha desarrollado un protocolo riguroso para definir
    ciudades, sub-ciudades y barrios. Este proceso nos permite estudiar y
    comparar entornos urbanos y sus impactos en la salud en ciudades de 11
    países de América Latina: Argentina, Brasil, Chile, Colombia, Costa Rica, El
    Salvador, Guatemala, México, Nicaragua, Panamá y Perú.
  </p>
  <p class="text-medium">
    Emprendimos un enfoque sistemático para identificar y definir las ciudades
    SALURBAL. El enfoque descrito a continuación ha guiado la definición de
    áreas geográficas a las que se vinculan todos los datos de SALURBAL. Puede
    leer más sobre este proceso en <a
      href="https://link.springer.com/article/10.1007/s11524-018-00326-0"
      target="_blank"
      >“Building a Data Platform for Cross-Country Urban Health Studies.”</a
    >
  </p>
</Section>

<Divider />

<Section>
  <h3>
    Paso 1. Identificación de ciudades con una población de 100,000 o más.
  </h3>
  <div class="two-col-container">
    <div class="left-col">
      <p class="text-medium">
        El universo de ciudades SALURBAL se definió como todas las
        aglomeraciones urbanas con al menos 100,000 residentes a partir de 2010.
      </p>
      <p class="text-medium">
        Utilizamos el <a
          href="http://atlasofurbanexpansion.org/"
          target="_blank">Atlas de Expansión Urbana</a
        >
        y los datos censales de los países de
        <a href="https://citypopulation.de/" target="_blank"
          >citypopulation.de</a
        > para obtener una lista de todas las ciudades (según se definen en estas
        fuentes) con 100,000 residentes o más en 2010. Combinamos ambas listas y
        eliminamos duplicados.
      </p>
    </div>
    <!-- 
  # ============================================================================ #
  # Map 1  (371 Salurbal cities)
-->
    <div class="right-col">
      <Media col="medium" caption="Interactive map of all 371 SALURBAL cities">
        <div class="chart-sml">
          <Map
            id="static_map_1"
            style="./data/style-osm-grey.json"
            location={{ bounds: bounds.southAmericaShifted }}
            controls={true}
            scales={false}
            dragPan={true}
            bind:map_static_1
            bind:center
          >
            <MapSource
              map_id="static_map_1"
              id="static_map_1-src"
              type="geojson"
              data={geojson_salurbal_centroid}
              promoteId={'l1_label'}
              maxzoom={13}
            >
              <MapLayer
                map_id="static_map_1"
                id="static_map_1-circle"
                type="circle"
                paint={{
                  'circle-color': hex_warning,
                  'circle-radius': 2.5,
                  'circle-stroke-color': 'black',
                  'circle-stroke-width': 0.1,
                }}
                hover={true}
                bind:hovered
              >
                <MapTooltip map_id="static_map_1" content={`${hovered}`} />
              </MapLayer>
            </MapSource>
          </Map>
        </div>
      </Media>
    </div>
  </div>
</Section>

<Section>
  <h3>Paso 2: Combinación de ciudades vecinas</h3>
  <p class="text-medium">
    Las ciudades que inicialmente se consideraron ciudades separadas se
    combinaron en una sola ciudad si formaban parte de la misma aglomeración, es
    decir, si sus áreas construidas estaban conectadas. Utilizamos el nombre de
    la ciudad con la mayor población para etiquetar estas unidades. En algunos
    casos donde las poblaciones eran casi iguales, asignamos un nombre con guion
    (por ejemplo, Valparaíso-Viña del Mar, Chile). Este proceso resultó en 371
    ciudades, a las que nos referimos como “ciudades SALURBAL”.
  </p>
</Section>

<Section>
  <h3>Paso 3: Definición de los límites geográficos de cada ciudad.</h3>
  <p class="text-medium">
    Operacionalizamos - o definimos geográficamente - cada ciudad SALURBAL
    utilizando unidades administrativas existentes a las que se pudiera vincular
    fácilmente datos de salud y otros datos. Estas unidades administrativas
    incluyeron <em>municipios</em>,
    <em>departamentos</em> o unidades similares en cada país.
  </p>
  <div style="display: flex; justify-content: center; align-items: center;">
    <Arrow color="black" animation={true} />
  </div>
</Section>

<div style="height: 3rem" />

<!-- 
  # ============================================================================ #
  # Scrolly 1  (define city boundaries)
-->
<Scroller {threshold} bind:id={id['map_scrolly_1']} splitscreen={true}>
  <div slot="background">
    <figure>
      <div class="col-full height-full">
        <Map
          id="map_scrolly_1"
          style="./data/style-esri-world-imagery.json"
          location={{ bounds: bounds.southAmerica }}
          controls={false}
          scales={true}
          hover={true}
          bind:hovered
          bind:map={map_scrolly_1}
          bind:zoom
          bind:center
        >
          {#if id.map_scrolly_1 == 'map08'}
            <div class="sticky-legend">
              <div class="boundary-metro-legend" />
              <div class="boundary-legend-text">
                Región Metropolitana de São Paulo definida localmente
              </div>
              <div class="boundary-sp-muni-legend" />
              <div class="boundary-legend-text">Municipalidad de São Paulo</div>
              <div class="boundary-l1-legend" />
              <div class="boundary-legend-text">
                Ciudad de São Paulo definida por SALURBAL
              </div>
            </div>
          {/if}
          <MapSource
            map_id="map_scrolly_1"
            id="municipio_centroid"
            type="geojson"
            data={geojson_municipio_centroid}
            promoteId={'municipio_centroid'}
            maxzoom={13}
          >
            <MapLayer
              map_id="map_scrolly_1"
              id="municipio_centroid"
              custom={custom_1}
              type="circle"
            />
            <MapPopup map_id="map_scrolly_1" custom={custom_1} />
          </MapSource>
          <MapSource
            map_id="map_scrolly_1"
            id="municipio"
            type="geojson"
            data={geojson_municipio}
            promoteId={src_municipio.code}
            maxzoom={13}
          >
            <MapLayer
              map_id="map_scrolly_1"
              id="municipio_line"
              custom={custom_1}
              type="line"
            />
          </MapSource>

          <MapSource
            map_id="map_scrolly_1"
            id="l2"
            type="geojson"
            data={geojson_l2}
            promoteId={src_l2.code}
            maxzoom={13}
          >
            <MapLayer
              map_id="map_scrolly_1"
              id="l2_line"
              custom={custom_1}
              type="line"
            />
            <MapLayer
              map_id="map_scrolly_1"
              id="l2_fill"
              custom={custom_1}
              type="fill"
            />
          </MapSource>
          <MapSource
            map_id="map_scrolly_1"
            id="l1ux"
            type="geojson"
            data={geojson_l1ux}
            promoteId={src_l1ux.code}
            maxzoom={13}
          >
            <MapLayer
              map_id="map_scrolly_1"
              id="l1ux"
              custom={custom_1}
              type="line"
            />
          </MapSource>
          <MapSource
            map_id="map_scrolly_1"
            id="l1ad"
            type="geojson"
            data={geojson_l1ad}
            promoteId={src_l1ad.code}
            maxzoom={13}
          >
            <MapLayer
              map_id="map_scrolly_1"
              id="l1ad_line"
              custom={custom_1}
              type="line"
            />
            <MapLayer
              map_id="map_scrolly_1"
              id="l1_fill"
              custom={custom_1}
              type="fill"
            />
          </MapSource>
          <MapSource
            map_id="map_scrolly_1"
            id="metro"
            type="geojson"
            data={geojson_metro}
            promoteId={src_metro.code}
            maxzoom={13}
          >
            <MapLayer
              map_id="map_scrolly_1"
              id="metro_line"
              custom={custom_1}
              type="line"
            />
          </MapSource>
          <MapSource
            map_id="map_scrolly_1"
            id="monterrey_l2"
            type="geojson"
            data={geojson_monterrey_l2}
            promoteId={src_monterrey_l2.code}
            maxzoom={13}
          >
            <MapLayer
              map_id="map_scrolly_1"
              id="monterrey_l2_line"
              custom={custom_1}
              type="line"
            />
          </MapSource>
          <MapSource
            map_id="map_scrolly_1"
            id="monterrey_unbuilt"
            type="geojson"
            data={geojson_monterrey_unbuilt}
            promoteId={src_monterrey_unbuilt.code}
            maxzoom={13}
          >
            <MapLayer
              map_id="map_scrolly_1"
              id="monterrey_unbuilt_fill"
              custom={custom_1}
              type="fill"
            />
          </MapSource>

          <MapSource
            map_id="map_scrolly_1"
            id="monterrey_l1ux"
            type="geojson"
            data={geojson_monterrey_l1ux}
            promoteId={src_monterrey_l1ux.code}
            maxzoom={13}
          >
            <MapLayer
              map_id="map_scrolly_1"
              id="monterrey_l1ux_line"
              custom={custom_1}
              type="line"
            />
          </MapSource>
          <MapSource
            map_id="map_scrolly_1"
            id="monterrey_l1ad"
            type="geojson"
            data={geojson_monterrey_l1ad}
            promoteId={src_monterrey_l1ad.code}
            maxzoom={13}
          >
            <MapLayer
              map_id="map_scrolly_1"
              id="monterrey_l1ad_line"
              custom={custom_1}
              type="line"
            />
          </MapSource>
          <MapSource
            map_id="map_scrolly_1"
            id="rio_cuarto_l1ad"
            type="geojson"
            data={geojson_rio_cuarto_l1ad}
            promoteId={src_rio_cuarto_l1ad.code}
            maxzoom={13}
          >
            <MapLayer
              map_id="map_scrolly_1"
              id="rio_cuarto_l1ad_line"
              custom={custom_1}
              type="line"
            />
            <MapLayer
              map_id="map_scrolly_1"
              id="rio_cuarto_l1ad_fill"
              custom={custom_1}
              type="fill"
            />
          </MapSource>
          <MapSource
            map_id="map_scrolly_1"
            id="rio_cuarto_l2"
            type="geojson"
            data={geojson_rio_cuarto_l2}
            promoteId={src_rio_cuarto_l2.code}
            maxzoom={13}
          >
            <MapLayer
              map_id="map_scrolly_1"
              id="rio_cuarto_l2_line"
              custom={custom_1}
              type="line"
            />
          </MapSource>
          <MapSource
            map_id="map_scrolly_1"
            id="rio_cuarto_l1ux"
            type="geojson"
            data={geojson_rio_cuarto_l1ux}
            promoteId={src_rio_cuarto_l1ux.code}
            maxzoom={13}
          >
            <MapLayer
              map_id="map_scrolly_1"
              id="rio_cuarto_l1ux_line"
              custom={custom_1}
              type="line"
            />
          </MapSource>
        </Map>
      </div>
    </figure>
  </div>

  <div slot="foreground">
    <section data-id="map01">
      <div class="col-medium">
        <p>Usaremos São Paulo, Brasil como ejemplo.</p>
      </div>
    </section>
    <section data-id="map02">
      <div class="col-medium">
        <p>
          Estas son las <span style={style_l2}>unidades administrativas</span>
          (<em>municipalidad</em>) en São Paulo, Brasil.
        </p>
      </div>
    </section>
    <section data-id="map04">
      <div class="col-medium">
        <p>
          A través de la inspección visual de imágenes satelitales,
          identificamos <span style={style_ux}>
            todas las unidades administrativas que incluían cualquier parte del
            área construida</span
          > de cada ciudad SALURBAL.
        </p>
      </div>
    </section>
    <section data-id="map05">
      <div class="col-medium">
        <p>
          La combinación de estas <span style={style_l2}
            >unidades administrativas</span
          >
          se considera una
          <span style={style_l1}>ciudad SALURBAL.</span>
        </p>
      </div>
    </section>
    <section data-id="map06">
      <div class="col-medium">
        <p>
          En casos donde las <span style={style_l2}
            >unidades administrativas</span
          >
          que componen una ciudad son muy grandes, una
          <span style={style_l1}>ciudad SALURBAL</span>
          puede incluir algunas áreas que no están
          <span style={style_unurban}>urbanizadas o construidas.</span> Esto se debe
          a que cualquier unidad administrativa que incluyera incluso una pequeña
          parte del área construida se incluyó en la definición geográfica de la
          ciudad.
        </p>
        <p>
          El ejemplo mostrado aquí es Monterrey, México con una población de
          alrededor de 5 millones de residentes. Algunos de los <em
            >municipios</em
          > incluidos como parte de Monterrey solo tienen una pequeña parte del área
          urbanizada de la ciudad.
        </p>
      </div>
    </section>
    <section data-id="map07">
      <div class="col-medium">
        <p>
          Mientras que algunas ciudades están compuestas por muchas de estas
          unidades, casi la mitad de las <span style={style_l1}
            >ciudades SALURBAL</span
          >
          incluyen solo una
          <span style={style_l2}>unidad administrativa</span>.
        </p>
        <p>
          El ejemplo mostrado aquí es Rio Cuarto, Argentina con una población de
          alrededor de 270,000 residentes. La <span style={style_ux}
            >ciudad</span
          >
          de Rio Cuarto está compuesta por un solo
          <span style={style_l2}><em>departamento</em></span>.
        </p>
      </div>
    </section>
    <section data-id="map08">
      <div class="col-medium text-medium">
        <p>
          Es importante destacar que las <span style={style_l1}
            >ciudades SALURBAL</span
          >
          pueden no coincidir con
          <span style={style_metro}>límites o definiciones políticas</span>
          que pueden ser más familiares para los funcionarios públicos y los residentes
          locales. Nuestros límites reflejan intencionadamente aglomeraciones urbanas
          que a menudo se extienden más allá de los núcleos de las ciudades.
        </p>

        <p>
          Este es el caso de São Paulo, Brasil, donde
          <span style={style_l1}
            >nuestra definición basada en la extensión construida</span
          >
          varía ligeramente en comparación con la
          <span style={style_metro}
            >Región Metropolitana de São Paulo definida localmente</span
          >
          , y se extiende más allá de la
          <span style={style_l2}>municipalidad de São Paulo</span>. Todas las
          definiciones de ciudades SALURBAL fueron revisadas por los miembros
          del equipo SALURBAL en cada país, antes de crear una lista final de
          371 ciudades.
        </p>
      </div>
    </section>
  </div>
</Scroller>

<Section>
  <h3>
    Paso 4. Creación de una jerarquía de unidades geográficas dentro de cada
    ciudad SALURBAL
  </h3>
  <p class="text-medium">
    Con el objetivo de capturar diferencias dentro de la ciudad y adaptarse a
    los datos disponibles para diferentes niveles geográficos, definimos
    unidades en múltiples "niveles" geográficos.
  </p>
  <p class="text-medium">
    Cada ciudad SALURBAL se refiere como una unidad de Nivel 1 (L1). Las
    unidades administrativas que componen cada ciudad (como se describió en el
    paso 3) se refieren a unidades de Nivel 2 (L2). También definimos unidades
    geográficas más pequeñas, similares a barrios anidados dentro de cada L2.
    Estas se refieren como unidades de Nivel 3 (L3s).
  </p>
  <p class="text-medium">
    En países donde no se definieron L3s para todo el territorio, SALURBAL creó
    proxies L3 combinando otras unidades geográficas disponibles. Cuando los L3s
    eran demasiado pequeños para nuestros propósitos de investigación, los
    barrios se representaron usando unidades ligeramente más grandes. Nos
    referimos a estos como unidades de Nivel 2.5 (L2.5s).
  </p>
  <p class="text-medium">
    Volvamos a São Paulo para ver cómo se aplican estos diferentes niveles
    geográficos a una ciudad real.
  </p>
  <div
    style="display: flex; justify-content: center; align-items: center; margin-top: 1rem;"
  >
    <Arrow color="black" animation={true} />
  </div>
</Section>

<!-- 
  # ============================================================================ #
  # Scrolly 2  (geographic units)
-->
<div style="height: 3rem" />
<Scroller {threshold} bind:id={id['map_scrolly_2']} splitscreen={true}>
  <div slot="background">
    <figure>
      <div class="col-full height-full">
        <Map
          id="map_scrolly_2"
          style="./data/style-esri-world-imagery.json"
          location={{ bounds: bounds.l1ad }}
          controls={false}
          scales={true}
          bind:map={map_scrolly_2}
          bind:zoom
          bind:center
        >
          <MapSource
            map_id="map_scrolly_2"
            id="municipio_centroid"
            type="geojson"
            data={geojson_municipio_centroid}
            promoteId={'municipio_centroid'}
            maxzoom={13}
          >
            <MapLayer
              map_id="map_scrolly_2"
              id="municipio_centroid"
              custom={custom_2}
              type="circle"
            />
          </MapSource>
          <MapSource
            map_id="map_scrolly_2"
            id="municipio"
            type="geojson"
            data={geojson_municipio}
            promoteId={src_municipio.code}
            maxzoom={13}
          >
            <MapLayer
              map_id="map_scrolly_2"
              id="municipio"
              custom={custom_2}
              type="line"
            />
          </MapSource>
          <MapSource
            map_id="map_scrolly_2"
            id="l3"
            type="geojson"
            data={geojson_l3}
            promoteId={src_l3.code}
            maxzoom={13}
          >
            <MapLayer
              map_id="map_scrolly_2"
              id="l3_line"
              custom={custom_2}
              type="line"
            />
          </MapSource>
          <MapSource
            map_id="map_scrolly_2"
            id="l25"
            type="geojson"
            data={geojson_l25}
            promoteId={src_l25.code}
            maxzoom={13}
          >
            <MapLayer
              map_id="map_scrolly_2"
              id="l25_line"
              custom={custom_2}
              type="line"
            />
          </MapSource>
          <MapSource
            map_id="map_scrolly_2"
            id="l2"
            type="geojson"
            data={geojson_l2}
            promoteId={src_l2.code}
            maxzoom={13}
          >
            <MapLayer
              map_id="map_scrolly_2"
              id="l2_line"
              custom={custom_2}
              type="line"
            />
            <MapLayer
              map_id="map_scrolly_2"
              id="l2_fill"
              custom={custom_2}
              type="fill"
            />
          </MapSource>
          <MapSource
            map_id="map_scrolly_2"
            id="l1ux"
            type="geojson"
            data={geojson_l1ux}
            promoteId={src_l1ux.code}
            maxzoom={13}
          >
            <MapLayer
              map_id="map_scrolly_2"
              id="l1ux"
              custom={custom_2}
              type="line"
            />
          </MapSource>
          <MapSource
            map_id="map_scrolly_2"
            id="l1ad"
            type="geojson"
            data={geojson_l1ad}
            promoteId={src_l1ad.code}
            maxzoom={13}
          >
            <MapLayer
              map_id="map_scrolly_2"
              id="l1ad_line"
              custom={custom_2}
              type="line"
            />
            <MapLayer
              map_id="map_scrolly_2"
              id="l1_fill"
              custom={custom_2}
              type="fill"
            />
          </MapSource>
          <MapSource
            map_id="map_scrolly_2"
            id="ex_l3"
            type="geojson"
            data={geojson_ex_l3}
            promoteId={src_ex_l3.code}
            maxzoom={13}
          >
            <MapLayer
              map_id="map_scrolly_2"
              id="ex_l3"
              custom={custom_2}
              type="line"
            />
          </MapSource>
          <MapSource
            map_id="map_scrolly_2"
            id="ex_l25"
            type="geojson"
            data={geojson_ex_l25}
            promoteId={src_ex_l25.code}
            maxzoom={13}
          >
            <MapLayer
              map_id="map_scrolly_2"
              id="ex_l25"
              custom={custom_2}
              type="line"
            />
          </MapSource>
          <MapSource
            map_id="map_scrolly_2"
            id="ex_l2"
            type="geojson"
            data={geojson_ex_l2}
            promoteId={src_ex_l2.code}
            maxzoom={13}
          >
            <MapLayer
              map_id="map_scrolly_2"
              id="ex_l2"
              custom={custom_2}
              type="line"
            />
          </MapSource>
        </Map>
      </div>
    </figure>
  </div>

  <div slot="foreground">
    <section data-id="map01">
      <div class="col-medium">
        <strong>Nivel 1: “Ciudades”</strong>
        <p>
          El <span style={style_l1}>Nivel 1</span> de SALURBAL para São Paulo
          abarca todas las unidades administrativas o
          <em>muncipalidades</em> que tienen cualquier superposición con el área
          urbana construida visualmente aparente en y alrededor de la ciudad principal
          de São Paulo.
        </p>
      </div>
    </section>
    <section data-id="map02">
      <div class="col-medium">
        <strong>Nivel 2: "Sub-ciudades"</strong>
        <p>
          Dentro de la ciudad SALURBAL de São Paulo <span style={style_l1}
            >(São Paulo L1)</span
          >, definimos unidades sub-ciudad como cada una de las
          <em>muncipalidades</em> que componen la aglomeración urbana de São
          Paulo. Estas son las <span style={style_l2}>L2s</span>.
        </p>
      </div>
    </section>
    <section data-id="map03">
      <div class="col-medium">
        <strong>Nivel 3: "Barrios"</strong>
        <p>
          Las <span style={style_l3}>unidades de Nivel 3 o barrios</span> son las
          unidades administrativas más pequeñas para las cuales hay datos del censo
          disponibles en cada país.
        </p>
      </div>
    </section>
    <section data-id="map04">
      <div class="col-medium">
        <strong>Nivel 3: "Barrios"</strong>
        <p>
          Como se muestra aquí, cada <span style={style_l3}>unidad L3</span> en
          una ciudad brasileña como São Paulo corresponde a un
          <em>setor censitario</em>.
        </p>
      </div>
    </section>
    <section data-id="map05">
      <div class="col-medium">
        <p>
          Estas <span style={style_l3}>unidades L3</span> a veces eran demasiado
          pequeñas para apoyar un análisis significativo a nivel de barrio. Para
          abordar este problema, utilizamos unidades geográficas del censo de
          Brasil más grandes (<em>Áreas de Ponderação</em>) y las etiquetamos
          como
          <span style={style_l25}>L2.5's</span>.
        </p>
      </div>
    </section>
    <section data-id="map06">
      <div class="col-medium">
        <p>
          La jerarquía de unidades geográficas de SALURBAL para Sao Paulo,
          Brasil consta de 621 <span style={style_l25}>
            unidades de barrio L2.5</span
          >, dentro de 31 <span style={style_l2}> unidades sub-ciudad L2</span>,
          dentro de una única <span style={style_l1}> unidad ciudad L1</span>.
        </p>
      </div>
    </section>
  </div>
</Scroller>

<Divider />

<Section>
  <h2>Entendiendo las diferencias inter e intra-ciudad</h2>
  <p class="text-medium">
    Este proceso se repitió para todas las 371 ciudades incluidas en el proyecto
    SALURBAL. El resultado es un recurso de datos sin precedentes que nos
    permite documentar y comparar diferencias en salud y bienestar tanto entre
    ciudades como dentro de ellas en toda América Latina. Puede encontrar
    ejemplos de análisis utilizando esta estructura de datos en nuestra <a
      href="https://drexel.edu/lac/data-evidence/publications/"
      target="_blank">lista de publicaciones</a
    >.
  </p>
  <p class="text-medium">
    Para obtener más información sobre las unidades específicas utilizadas en
    cada país de SALURBAL, consulte nuestro artículo en el <a
      href="https://link.springer.com/article/10.1007/s11524-018-00326-0"
      target="_blank">Journal of Urban Health</a
    >.
  </p>
  <p class="text-medium">
    Para obtener más detalles y acceso a estos límites, consulte nuestro <a
      href="https://data.lacurbanhealth.org/"
      target="_blank">repositorio de datos espaciales</a
    >
    en el
    <a href="https://data.lacurbanhealth.org/" target="_blank"
      >portal de datos de SALURBAL</a
    >.
  </p>
</Section>

<UHCFooter />

<!-- 
  # ============================================================================ #
  #  ............... style ...............
-->

<style>
  /* Styles specific to elements within the demo */
  :global(svelte-scroller-foreground) {
    pointer-events: none !important;
  }
  :global(svelte-scroller-foreground section div) {
    pointer-events: all !important;
  }
  select {
    max-width: 350px;
  }
  .sticky-legend {
    position: fixed;
    bottom: 2%;
    right: 1%;
    /* transform: translate(-50%, -50%); */
    border-radius: 5px;
    background-color: white;
    padding: 10px;
    z-index: 9999;
    /*Grid Stuff */
    display: grid;
    align-items: center;
    grid-template-columns: min-content 1fr;
  }
  .boundary-legend-text {
    /* max-width: 10rem; */
    padding-left: 0.5rem;
    font-size: 1.25em;
  }

  .boundary-metro-legend {
    width: 2rem;
    height: 5px;
    background-color: #8c198c;
  }
  .boundary-sp-muni-legend {
    width: 2rem;
    height: 5px;
    margin-top: 15px;
    margin-bottom: 15px;
    background-color: #2f8fbc;
  }
  .boundary-l1-legend {
    width: 2rem;
    height: 5px;
    background-color: #bc3b2f;
  }
  .stickDev {
    position: fixed;
    bottom: 10%;
    left: 10%;
    /* transform: translate(-50%, -50%); */
    background-color: white;
    color: red;
    padding: 10px;
    z-index: 9999;
  }
  .chart {
    margin-top: 45px;
    width: calc(100% - 5px);
  }
  .chart-full {
    margin: 0 20px;
  }
  .chart-sml {
    font-size: 0.85em;
    height: 350px;
  }
  /* The properties below make the media DIVs grey, for visual purposes in demo */
  .media {
    background-color: #f0f0f0;
    display: -webkit-box;
    display: -ms-flexbox;
    display: flex;
    -webkit-box-orient: vertical;
    -webkit-box-direction: normal;
    -ms-flex-flow: column;
    flex-flow: column;
    -webkit-box-pack: center;
    -ms-flex-pack: center;
    justify-content: center;
    text-align: center;
    color: #aaa;
  }

  .two-col-container {
    display: flex;
    justify-content: space-between;
  }

  .left-col {
    flex: 3; /* Takes up 1 part of the available space */
    /* border: 1px solid black; */
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
  }

  .right-col {
    flex: 3; /* Takes up 1 part of the available space */
    /* border: 1px solid black; */
    margin-top: 0.5rem;
  }

  /* Responsive layout for small screens */
  @media (max-width: 768px) {
    .two-col-container {
      flex-direction: column;
    }

    .left-col,
    .right-col {
      flex: 1;
      width: 100%;
    }
  }
</style>
