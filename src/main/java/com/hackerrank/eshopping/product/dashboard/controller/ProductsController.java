package com.hackerrank.eshopping.product.dashboard.controller;

import com.hackerrank.eshopping.product.dashboard.DebugLogger;
import com.hackerrank.eshopping.product.dashboard.model.Product;
import com.hackerrank.eshopping.product.dashboard.model.Status;
import com.hackerrank.eshopping.product.dashboard.model.UpdateData;
import com.hackerrank.eshopping.product.dashboard.service.ProductService;
import java.util.ArrayList;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * JSON keys:
 *
 * id:                  Unique product ID
 * name:                Product name
 * category:            Product category
 * retail_price:        Product retail price to 2 decimal places
 * discounted_price:    Current selling price to 2 decimal places
 * availability:        Is product in stock
 *
 * @author Paul G. Allen <pgallen@gmail.com>
 * 
 */

@RestController
public class ProductsController
{
    private final boolean DEBUG = true;
    @Autowired ProductService productService;

    /**
     * Adds a new product. The product JSON is in the request body.
     * @param product
     * @return Status code 400 if product exists, 201 otherwise
     * 
     */
    @PostMapping (value = "/products")
    public ResponseEntity<String> addProduct (@RequestBody Product product)
    {
        ResponseEntity<String> response = new ResponseEntity<> (HttpStatus.CREATED);
        Product newProd;

        DebugLogger.debug (DEBUG, "In addProduct");

        newProd = productService.createProduct (product);

        if (newProd != null)
        {
            DebugLogger.debug (DEBUG, "\nProduct ID: " + newProd.getId() + ", "
                                    + "Category: " + newProd.getCategory() + ", "
                                    + "Retail: " + newProd.getRetail_price() + ", "
                                    + "Discounted: " + newProd.getDiscounted_price() + ", "
                                    + "Availability: " + newProd.getAvailability() + "\n"
                              );
        }
        else
        {
            response = new ResponseEntity<> (HttpStatus.BAD_REQUEST);
            DebugLogger.debug (DEBUG, "Duplicate Product");
        }

        return response;
    }

    /**
     * Return a product by ID.
     *
     * @param product_id
     * @return 200 on success, 404 otherwise
     * 
     */
    @GetMapping (value = "/products/{product_id}")
    public ResponseEntity<Product> getProductById (@PathVariable Long product_id)
    {
        ResponseEntity<Product> response;
        Product product;

        DebugLogger.debug (DEBUG, "In getProductById");

        product = productService.getProduct (product_id);

        if (product == null)
        {
            DebugLogger.debug (DEBUG, "No product found");
            response = new ResponseEntity<> (HttpStatus.NOT_FOUND);
        }
        else
        {
            DebugLogger.debug (DEBUG, "Product found");
            DebugLogger.debug (DEBUG, "\nProduct ID: " + product.getId() + ", "
                                      + "Category: " + product.getCategory() + ", "
                                      + "Retail: " + product.getRetail_price() + ", "
                                      + "Discounted: " + product.getDiscounted_price() + ", "
                                      + "Availability: " + product.getAvailability() + "\n"
                              );
            response = new ResponseEntity<Product> (product, HttpStatus.OK);
        }

        return response;
    }

    /**
     * Update a product by ID. The product JSON contains:
     *      retail_price:       May remain unchanged
     *      discounted_price:   May remain unchanged
     *      availability:       May remain unchanged
     *
     * @param product_id
     * @param updateData
     * @param id
     * @return Status 200 if updated, 400 if not exist
     * 
     */
    @PutMapping (value = "/products/{product_id}")
    public ResponseEntity<String> updateProduct (@PathVariable Long product_id, @RequestBody UpdateData updateData)
    {
        ResponseEntity<String> response = new ResponseEntity<> (HttpStatus.OK);
        Product product;

        DebugLogger.debug (DEBUG, "In updateProduct");

        product = productService.getProduct (product_id);

        if (product != null)
        {
            DebugLogger.debug (DEBUG, "Product ID: " + product.getId() + ", "
                                 + "Retail: " + product.getRetail_price() + ", "
                                 + "Discounted: " + product.getDiscounted_price() + ", "
                                 + "Availability: " + product.getAvailability()
                              );

            DebugLogger.debug (DEBUG, "Update ID: " + product_id + ", "
                                    + "Retail: " + updateData.getRetail_price() + ", "
                                    + "Discounted: " + updateData.getDiscounted_price() + ", "
                                    + "Availability: " + updateData.getAvailability()
                              );
            product.setAvailability (updateData.getAvailability());
            product.setDiscounted_price (updateData.getDiscounted_price());
            product.setRetail_price (updateData.getRetail_price());
            Product newProd = productService.updateProduct (product);

            if (newProd != null)
            {
                DebugLogger.debug (DEBUG, "Product ID: " + newProd.getId() + ", "
                                        + "Retail: " + newProd.getRetail_price() + ", "
                                        + "Discounted: " + newProd.getDiscounted_price() + ", "
                                        + "Availability: " + newProd.getAvailability()
                                     );
            }
            else
            {
                DebugLogger.debug (DEBUG, "Failed to update product");
            }
        }
        else
        {
            response = new ResponseEntity<> (HttpStatus.BAD_REQUEST);
        }

        return response;
    }

    /**
     * Returns all products matching the given category. Products sorted by availability,
     * in stock first, then discounted price, then product ID in ascending order.
     *
     * @param category
     * @return Status code 200
     * 
     */
    @GetMapping (value = "/products", params = {"category"})
    public ResponseEntity<List<Product>> getProductsByCategory (@RequestParam (value = "category") String category)
    {
        List<Product> prodList;

        DebugLogger.debug (DEBUG, "In getProductsByCategory: " + category);

        prodList = productService.getProductByCat (category);

        return new ResponseEntity<> (prodList, HttpStatus.OK);
    }

    /**
     * Return products by category and availability. Sort by discount percentage in
     * descending order, then discounted price in ascending order, then product ID in
     * ascending order
     *
     * DisPercent = (retail - discounted)/retail * 100
     *
     * @param category
     * @param availability
     * @return
     * 
     */
    @GetMapping (value = "/products",  params = {"category", "availability"})
    public ResponseEntity<List<Product>> getproductByCatAndAvail (@RequestParam (value = "category") String category, @RequestParam (value = "availability") boolean availability)
    {
        List<Product> prodList = new ArrayList<>();

        DebugLogger.debug (DEBUG, "In getproductByCatAndAvail: " + category + ", " + availability);

        prodList = productService.getProductByCatAndAvail (category, availability);

        return new ResponseEntity<> (prodList, HttpStatus.OK);
    }

    /**
     * Get all products. Sort by product ID in ascending order
     *
     * @return Status 200 with list of products
     * 
     */
    @GetMapping (value = "/products")
    public ResponseEntity<List<Product>> getProducts()
    {
        List<Product> prodList = productService.getProducts();

        DebugLogger.debug (DEBUG, "In getProducts");

        return new ResponseEntity<> (prodList, HttpStatus.OK);
    }
    
    /**
     * Check the status of the system
     * 
     * @return status of 200 and a status message
     * 
     */
    @GetMapping (value = "/status")
    public ResponseEntity<Status> getStatus()
    {
        Status status = new Status();
        
        DebugLogger.debug (DEBUG, "In getStatus");
        
        return new ResponseEntity<> (status, HttpStatus.OK);
    }
}
