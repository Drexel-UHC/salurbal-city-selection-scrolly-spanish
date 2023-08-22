{ # Setup -------------------------------------------------------------------
  
  ## Dependencies 
    library(tidyverse)
    library(geojsonio)  
    library(geoarrow)
    library(glue)
    library(curl)  
    library(leaflet)
    library(sf)
    library(rmapshaper)
    library(leaflet)
    library(stringi) 
    library(geoarrow)
    library(geojsonsf)
 
  ## Local objects
  salid1_tmp= 102248
  clean_path = '../../salurbal-fair-renovations/clean/seeds/spatial'

  }


{ # Topojsons -------------------------------------------------------
  

  { ## sf__metropolitan  ----------------------------------------------------------------
    dir_MAID2 =paste0('//files.drexel.edu/colleges/SOPH/Shared/UHC/Projects/Wellcome_Trust/Data Methods Core/Geodatabases/SALURBAL_1_4_21/BR_1_4_21/BR_SALURBAL_1_4_21.gdb')
    layers_MAID2 = sf::st_layers(dir_MAID2)
    stg__MAID2 = sf::st_read(dir_MAID2,"BRMUN_SALURBAL_7_6_21")%>%  
      sf::st_transform("+proj=longlat +datum=NAD83")
    
    sf__metropolitan_raw = stg__MAID2 %>% filter(SALMAID1 == 9102248) 
    
    sf__metropolitan_merged = sf__metropolitan_raw %>% 
      st_make_valid()  %>% 
      st_cast("MULTIPOLYGON")%>%
      st_union()  
    sf__metropolitan_clean <- st_sf(geometry = st_sfc(st_polygon(list(sf__metropolitan_merged[[1]][[1]]))))
    sf__metropolitan = sf__metropolitan_clean %>% ms_simplify(keep = 0.05,keep_shapes = T)
    
    ## Export
    sf__metropolitan %>% 
      geojsonio::topojson_write(
        file = "../public/data/sao_paolo_metro.json",
        object_name  = 'geog')
    
  }
  
  { ## sf__l1  -----------------------------------------------------------
    sf__l1 = geoarrow::read_geoparquet_sf(glue("{clean_path}/sf__L1_simp_5pct.parquet")) %>%
      filter(salid1 == salid1_tmp)
    
    ## Export
    sf__l1 %>% 
      geojsonio::topojson_write(
        file = "../public/data/sao_paolo_l1ad.json",
        object_name  = 'geog')
  }   
  
  { ## sf__l1ux -----------------------------------------------------------
    sf__l1ux = geoarrow::read_geoparquet_sf(glue("{clean_path}/sf__L1UX_simp_5pct.parquet"))  %>%
      filter(salid1 == salid1_tmp)    
    
    ## Export
    sf__l1ux %>% 
      geojsonio::topojson_write(
        file = "../public/data/sao_paolo_l1ux.json",
        object_name  = 'geog')
  }
  
  { ## sf__l2 -----------------------------------------------------------
    sf__l2 =  geoarrow::read_geoparquet_sf(glue("{clean_path}/sf__L2_simp_5pct.parquet"))  %>% 
      filter(salid1 == salid1_tmp)
    
    ## Export
    sf__l2 %>% 
      geojsonio::topojson_write(
        file = "../public/data/sao_paolo_l2.json",
        object_name  = 'geog')
    }
  
  { ## sf__l2_5 -----------------------------------------------------------
    sf__l2_5 =  geoarrow::read_geoparquet_sf(glue("{clean_path}/sf__L25_simp_5pct.parquet"))  %>% 
      filter(salid1 == salid1_tmp)
    
    ## Export
    sf__l2_5 %>% 
      geojsonio::topojson_write(
        file = "../public/data/sao_paolo_l25.json",
        object_name  = 'geog')
    }
  
  { ## sf__l3 -----------------------------------------------------------
    sf__l3 =  geoarrow::read_geoparquet_sf(glue("{clean_path}/sf__L3_simp_5pct.parquet"))  %>% 
      filter(salid1 == salid1_tmp)  
    
    ## Export
    sf__l3 %>% 
      geojsonio::topojson_write(
        file = "../public/data/sao_paolo_l3.json",
        object_name  = 'geog')
  }
  
  { ## sf_sp_municipio  -------------------------------------------------------------
    sf_sp_municipio = sf__l2 %>% 
      filter(salid2 == 10224810 )
    
    ## Export
    sf_sp_municipio %>% 
      geojsonio::topojson_write(
        file = "../public/data/sao_paolo_municipio.json",
        object_name  = 'geog')
  }
  
  
}

{ # Centroids ---------------------------------------------------------------
  
  { ## sf_sp_municipio_centroid  -------------------------------------------------------------
    sf_sp_municipio_centroid = st_centroid(sf_sp_municipio)
    
    ## Export
    sf_sp_municipio_centroid %>% 
      geojsonio::topojson_write(
        file = "../public/data/sao_paolo_municipio_centroid.json",
        object_name  = 'geog')
  }
  
  { ## sf_sp_l1ad_centroid  -------------------------------------------------------------
    sf_sp_l1ad_centroid = st_centroid(sf__l1_tmp)
    
    ## Export
    sf_sp_l1ad_centroid %>% 
      geojsonio::topojson_write(
        file = "../public/data/sao_paolo_l1ad_centroid.json",
        object_name  = 'geog')
  }
 
  
}
 
{ # EDA ---------------------------------------------------------------------
    
  leaflet() %>% 
    addTiles() %>% 
    addCircles(data = sf_sp_municipio_centroid)
    # addPolygons(data = sf__l1_tmp, fillOpacity = 0) %>%
    # addPolygons(data = sf__metropolitan_tmp, color = 'red', fillOpacity = 0)  
  
}

