/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.hackerrank.eshopping.product.dashboard.service;

import com.hackerrank.eshopping.product.dashboard.DebugLogger;
import com.hackerrank.eshopping.product.dashboard.interfaces.ProductDao;
import com.hackerrank.eshopping.product.dashboard.model.Product;
import com.hackerrank.eshopping.product.dashboard.model.ProductModel;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 *
 * @author Paul G. Allen <pgallen@gmail.com>
 */
@Service
public class ProductService implements Serializable
{
    private static final long serialVersionUID = 1L;
    
    private final boolean DEBUG = true;
    @Autowired ProductDao productDao;

    public Product createProduct (final Product product)
    {
        Product productData = null;
        ProductModel productModel = new ProductModel();

        if (!productDao.existsById (product.getId()))
        {
            BeanUtils.copyProperties (product, productModel);
            productModel = productDao.save (productModel);
            productData = new Product();
            BeanUtils.copyProperties (productModel, productData);
        }
        // else do nothing

        return productData;
    }

    public List<Product> getProducts()
    {
        List<ProductModel> products = new ArrayList<>();
        List<Product> productList = new ArrayList<>();

        productDao.findAll().forEach (products::add);

        for (ProductModel productModel : products)
        {
            Product product = new Product();
            BeanUtils.copyProperties (productModel, product);
            productList.add (product);
        }

        return productList;
    }

    public Product getProduct (Long id)
    {
        Product productData = null;
        ProductModel model = new ProductModel();

        if (productDao.existsById (id))
        {
            Optional<ProductModel> productModel;
            productData = new Product();
            DebugLogger.debug (DEBUG, "Product " + id + " Found");
            productModel = productDao.findById (id);

            model = productModel.get();
            DebugLogger.debug (DEBUG, "\nProduct ID: " + model.getId() + ", "
                                    + "Category: " + model.getCategory() + ", "
                                    + "Retail: " + model.getRetail_price() + ", "
                                    + "Discounted: " + model.getDiscounted_price() + ", "
                                    + "Availability: " + model.getAvailability() + "\n"
                              );

            BeanUtils.copyProperties (productModel.get(), productData);
        }
        else
        {
            DebugLogger.debug (DEBUG, "Product " + id + " NOT FOUND");
        }

        return productData;
    }

    public Product updateProduct (final Product product)
    {
        Product productData = null;
        ProductModel productModel = new ProductModel();

        if (productDao.existsById (product.getId()))
        {
            BeanUtils.copyProperties (product, productModel);
            productModel = productDao.save (productModel);
            productData = new Product();
            BeanUtils.copyProperties (productModel, productData);
        }
        // else do nothing

        return productData;
    }

    public List<Product> getProductByCat (String category)
    {
        List<ProductModel> modelList;
        List<Product> prodList = new ArrayList<>();
        Product productData;

        DebugLogger.debug (DEBUG, "In getProductByCat()");

        modelList = productDao.findByCategory (category);

        for (ProductModel model : modelList)
        {
            productData = new Product();
            BeanUtils.copyProperties (model, productData);
            prodList.add (productData);
        }

        return prodList;
    }

    public List<Product> getProductByCatAndAvail (String category, boolean availability)
    {
        List<ProductModel> modelList;
        List<Product> prodList = new ArrayList<>();
        Product productData;

//        modelList = productDao.findByCategoryAndAvailability (category, availability);
        modelList = productDao.findByCategoryAndAvailability (category, availability);

        for (ProductModel model : modelList)
        {
            productData = new Product();
            BeanUtils.copyProperties (model, productData);
            prodList.add (productData);
        }

        return prodList;
    }

    public void deleteProduct (Long id)
    {
        productDao.deleteById (id);
    }
    
    @Transactional
    public void truncateTable()
    {
        productDao.truncateTable();
    }
}
