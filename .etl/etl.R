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

{ # Sao Paolo ---------------------------------------------------------------
 
   { ## Topojsons -------------------------------------------------------
    
    
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
      sf__l3_5pct =  geoarrow::read_geoparquet_sf(glue("{clean_path}/sf__L3_simp_5pct.parquet"))  %>% 
        filter(salid1 == salid1_tmp) 
      
      sf__l3 = sf__l3_5pct %>% ms_simplify(keep = 0.05, keep_shapes = T)
      
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
  
  { ## Centroids ---------------------------------------------------------------
    
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
    
    { ## sf_sp_l2_centroid  -------------------------------------------------------------
      sf_sp_l2_centroid = st_centroid(sf__l2_tmp)
      
      ## Export
      sf_sp_l2_centroid %>% 
        geojsonio::topojson_write(
          file = "../public/data/sao_paolo_l2_centroid.json",
          object_name  = 'geog')
    }
  }
  
}


{ ## Monterrey (un-urbanized area)   -------------------------------------------------------------
  
  { ## sf__monterrey_l1  -----------------------------------------------------------
    sf__monterrey_l1 = geoarrow::read_geoparquet_sf(glue("{clean_path}/sf__L1_simp_5pct.parquet")) %>%
      filter(l1_label == 'Monterrey')
    
    ## Export
    sf__monterrey_l1 %>% 
      geojsonio::topojson_write(
        file = "../public/data/monterrey_l1ad.json",
        object_name  = 'geog')
  }   
  
  { ## sf__monterrey_l1ux -----------------------------------------------------------
    sf__monterrey_l1ux = geoarrow::read_geoparquet_sf(glue("{clean_path}/sf__L1UX_simp_5pct.parquet"))  %>%
      filter(l1_label == 'Monterrey')
    
    ## Export
    sf__monterrey_l1ux %>% 
      geojsonio::topojson_write(
        file = "../public/data/monterrey_l1ux.json",
        object_name  = 'geog')
  }
  
  { ## sf__monterrey_l2  -----------------------------------------------------------
    sf__monterrey_l2 = geoarrow::read_geoparquet_sf(glue("{clean_path}/sf__L2_simp_5pct.parquet")) %>%
      filter(l1_label == 'Monterrey')
    
    ## Export
    sf__monterrey_l2 %>% 
      geojsonio::topojson_write(
        file = "../public/data/monterrey_l2.json",
        object_name  = 'geog')
  }   
  
  { ## sf__monterrey_unbuilt -----------------------------------------------------------
    sf__monterrey_unbuilt = st_difference(sf__monterrey_l1, sf__monterrey_l1ux)
    
    ## Export
    sf__monterrey_unbuilt %>% 
      geojsonio::topojson_write(
        file = "../public/data/monterrey_unbuilt.json",
        object_name  = 'geog')
  }
  
}

{ ## Rio Cuarto (single L2)   -------------------------------------------------------------
  
  { ## sf__rio_cuarto_l1  -----------------------------------------------------------
    sf__rio_cuarto_l1 = geoarrow::read_geoparquet_sf(glue("{clean_path}/sf__L1_simp_5pct.parquet")) %>%
      filter(l1_label == 'Rio Cuarto')
    
    ## Export
    sf__rio_cuarto_l1 %>% 
      geojsonio::topojson_write(
        file = "../public/data/rio_cuarto_l1ad.json",
        object_name  = 'geog')
  }   
  
  { ## sf__rio_cuarto_l1ux -----------------------------------------------------------
    sf__rio_cuarto_l1ux = geoarrow::read_geoparquet_sf(glue("{clean_path}/sf__L1UX_simp_5pct.parquet"))  %>%
      filter(l1_label == 'Rio Cuarto')
    
    ## Export
    sf__rio_cuarto_l1ux %>% 
      geojsonio::topojson_write(
        file = "../public/data/rio_cuarto_l1ux.json",
        object_name  = 'geog')
  }
  
  { ## sf__rio_cuarto_l2  -----------------------------------------------------------
    sf__rio_cuarto_l2 = geoarrow::read_geoparquet_sf(glue("{clean_path}/sf__L2_simp_5pct.parquet")) %>%
      filter(l2_label == 'Rio Cuarto')
    
    ## Export
    sf__rio_cuarto_l2 %>% 
      geojsonio::topojson_write(
        file = "../public/data/rio_cuarto_l2.json",
        object_name  = 'geog')
  } 
}

{ ## SALURBAL centroids   -------------------------------------------------------------
  
  sf_sp_l1ad_centroid = geoarrow::read_geoparquet_sf(glue("{clean_path}/sf__L1_centroids.parquet")) 
  
  ## Export
  sf_sp_l1ad_centroid %>% 
    geojsonio::topojson_write(
      file = "../public/data/salurbal_l1ad_centroid.json",
      object_name  = 'geog')
}


{ # EDA ---------------------------------------------------------------------
  
  leaflet() %>% 
    addTiles() %>% 
    addPolygons(data = sf__rio_cuarto_l2, fillOpacity = 0)
}



{ # Scrolly Drafts ----------------------------------------------------------
  
  ## Step 3 ------------------------------------------------------------------
  ##' Through visual inspection of satellite imagery, we identified all administrative units 
  ##' that included any portion of the built-up area of each SALURBAL city.  
  ##' 
  ##' Zoom into the center of the urban area and then move out to the fringe of 
  ##' the urban extent, following it a short distance to illustrate the process 
  ##' of detecting the visually apparent built-up area
  
  leaflet() %>% 
    addTiles() %>% 
    addPolygons(data = sf__monterrey_l2, fillOpacity = 0, color = 'green') 
  

# Scrolly 2 - L2s ---------------------------------------------------------

  
  sfa = sf_sp_l2_centroid  
    
    leaflet() %>% 
    addTiles()  %>% 
    addPolygons(data = sf__l2, fillOpacity = 0) %>% 
    addCircleMarkers(data = sf_sp_l2_centroid)
  
  
}

